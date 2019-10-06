FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    python \
    python-pip \
    python-dev \
    python-setuptools \
    locales \
    cmake \
    curl \
    libreadline-dev \
    ncurses-dev \
    bzip2 \
    zlib1g-dev \
    libbz2-dev \
    libssl-dev \
    vim \
    libxml2 \
    libxslt1.1 \
    wget \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libxcursor-dev \
    libxext-dev \
    libxfixes-dev \
    libxft-dev \
    libxrandr-dev \
    libxrender-dev \
    libglew-dev \
    libglfw3-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

RUN mkdir -p /var/qt_build
WORKDIR /var/qt_build
RUN wget https://download.qt.io/archive/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.tar.gz
RUN tar -xzvf qt-everywhere-opensource-src-4.8.6.tar.gz
WORKDIR /var/qt_build/qt-everywhere-opensource-src-4.8.6
RUN ./configure -prefix ~/Lib/Qt-4.8.6 -opensource -confirm-license -no-qt3support -nomake examples -nomake demos
RUN make -j 3 && make install
ENV PATH $PATH:/root/Lib/Qt-4.8.6/bin/
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/root/Lib/Qt-4.8.6/lib

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

RUN mkdir -p /var/fbxsdk
COPY ./lib/fbx20190_fbxsdk_linux.tar.gz /var/fbxsdk/fbxsdk_linux.tar.gz
WORKDIR /var/fbxsdk
RUN tar xvzf fbxsdk_linux.tar.gz
RUN chmod ugo+x fbx20190_fbxsdk_linux
RUN yes yes | ./fbx20190_fbxsdk_linux /usr

COPY ./src/USD /var/USD
RUN python /var/USD/build_scripts/build_usd.py /usr/local/USD -j 4
ENV PATH $PATH:/usr/local/USD/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/USD/lib
ENV PYTHONPATH $PYTHONPATH:/usr/local/USD/lib/python
