FROM mcr.microsoft.com/devcontainers/javascript-node:22

RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libglib2.0-dev \
    libexpat1-dev \
    cmake \
    curl \
    git \
    clang \
    python3-pip \
    ninja-build \
    meson \
    gnupg

RUN apt-get install -y \
    libde265-dev \
    libx265-dev \
    libheif-dev \
    libjxl-dev \
    libwebp-dev \
    libniftiio-dev \
    libcfitsio-dev \
    libfftw3-dev \
    libtiff-dev \
    libopenexr-dev \
    libjpeg-dev \
    libmatio-dev \
    libimagequant-dev \
    libhwy-dev

WORKDIR /tmp
RUN curl -LO https://github.com/libvips/libvips/releases/download/v8.16.1/vips-8.16.1.tar.xz && \
    tar -xf vips-8.16.1.tar.xz && \
    cd vips-8.16.1 && \
    meson setup build --prefix /usr/local/ && \
    cd build && \
    meson compile && \
    meson install && \
    ldconfig

RUN apt-get update && apt-get install -y \
    ca-certificates \
    gnupg \
    curl \
    libjemalloc2 \
    libjemalloc-dev \
    libglib2.0-0 \
    libde265-0 \
    libheif1 \
    libjxl0.7 \
    libwebp7 \
    libniftiio2 \
    libcfitsio10 \
    libtiff6 \
    libopenexr-3-1-30 \
    libjpeg62-turbo \
    libfftw3-double3 \
    libfftw3-single3 \
    && apt-get clean

ENV SHARP_IGNORE_GLOBAL_LIBVIPS=0