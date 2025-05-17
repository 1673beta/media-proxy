FROM ubuntu:noble AS builder

# Install essential packages
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

# Install libvips optional dependencies
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

# Install libvips
WORKDIR /tmp
RUN curl -LO https://github.com/libvips/libvips/releases/download/v8.16.1/vips-8.16.1.tar.xz && \
    tar -xf vips-8.16.1.tar.xz && \
    cd vips-8.16.1 && \
    meson setup build --prefix /usr/local/ && \
    cd build && \
    meson compile && \
    meson install && \
    ldconfig

RUN find /usr -name "vips*.pc"

# Install Node.js
ENV NODE_MAJOR=22
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs

# Install pnpm
RUN npm install -g pnpm@10.10.0

WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY server.js config.js ./

ENV SHARP_IGNORE_GLOBAL_LIBVIPS=0
RUN pnpm install --frozen-lockfile
COPY src/ ./src/
COPY tsconfig.json ./
RUN pnpm run build

FROM ubuntu:noble AS runner

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
    libjpeg8 \
    libfftw3-double3 \
    libfftw3-single3 \
    && apt-get clean

ENV NODE_MAJOR=22
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs

RUN npm install -g pnpm@10.10.0

COPY --from=builder /usr/local/lib/libvips* /usr/local/lib/
COPY --from=builder /usr/local/lib/*/pkgconfig/vips*.pc /usr/local/lib/pkgconfig/
COPY --from=builder /usr/local/include/vips /usr/local/include/vips

RUN ldconfig

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/built ./built
COPY --from=builder /app/package.json /app/server.js /app/config.js ./

ENV SHARP_IGNORE_GLOBAL_LIBVIPS=0
ENV NODE_ENV=production

RUN find /usr -name "*jemalloc.so*"
RUN ln -sf $(find /usr/lib -name "*jemalloc.so*" | head -n 1) /usr/local/lib/libjemalloc.so
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so
ENV MALLOC_CONF=background_thread:true,metadata_thp:auto,dirty_decay_ms:30000,muzzy_decay_ms:30000

RUN groupadd -r mediaproxy && useradd -r -g mediaproxy mediaproxy
RUN chown -R mediaproxy:mediaproxy /app
USER mediaproxy

CMD ["pnpm", "run", "start"]
