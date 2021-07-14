FROM node:12-buster-slim

# ShinobiPro branch, defaults to dev
ARG APP_BRANCH=dev

ENV DB_USER=majesticflame \
    DB_PASSWORD='' \
    DB_HOST='localhost' \
    DB_DATABASE=ccio \
    DB_PORT=3306 \
    SUBSCRIPTION_ID=sub_XXXXXXXXXXXX \
    PLUGIN_KEYS='{}' \
    SSL_ENABLED='false' \
    SSL_COUNTRY='CA' \
    SSL_STATE='BC' \
    SSL_LOCATION='Vancouver' \
    SSL_ORGANIZATION='Shinobi Systems' \
    SSL_ORGANIZATION_UNIT='IT Department' \
    SSL_COMMON_NAME='nvr.ninja' \
    DB_DISABLE_INCLUDED=true
ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /home/Shinobi /config /var/lib/mysql

RUN apt update -y
RUN apt install wget curl net-tools -y

RUN apt update --fix-missing
RUN apt install -y software-properties-common \
        libfreetype6-dev \
        libgnutls28-dev \
        libmp3lame-dev \
        libass-dev \
        libogg-dev \
        libtheora-dev \
        libvorbis-dev \
        libvpx-dev \
        libwebp-dev \
        libssh2-1-dev \
        libopus-dev \
        librtmp-dev \
        libx264-dev \
        libx265-dev \
        yasm \
        --no-install-recommends
RUN apt install -y \
        build-essential \
        bzip2 \
        coreutils \
        procps \
        gnutls-bin \
        nasm \
        tar \
        x264 \
        --no-install-recommends
RUN apt install -y \
        ffmpeg \
        git \
        make \
        mariadb-client \
        g++ \
        gcc \
        pkg-config \
        python3 \
        wget \
        tar \
        sudo \
        xz-utils \
        --no-install-recommends
RUN apt install -y \
        mc \
        htop \
        nano \
        --no-install-recommends

# install latest ffmpeg static build
RUN wget -q https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz \
    && tar xpf ./ffmpeg-git-amd64-static.tar.xz -C ./ \
    && cp -f ./ffmpeg-git-*-amd64-static/ff* /usr/bin/ \
    && chmod +x /usr/bin/ff* \
    && rm -f ffmpeg-git-amd64-static.tar.xz \
    && rm -rf ./ffmpeg-git-*-amd64-static

# Assign working directory
WORKDIR /home/Shinobi

RUN git clone -b ${APP_BRANCH}  https://bitbucket.org/ShinobiSystems/shinobi.git /home/Shinobi
RUN rm -rf /home/Shinobi/plugins
RUN rm -rf package-lock.json
RUN cp ./Docker/pm2.yml ./

RUN npm i npm@latest -g && \
    npm install pm2 -g && \
    npm install --unsafe-perm

# Copy default configuration files
RUN chmod -f +x /home/Shinobi/Docker/init.sh

VOLUME ["/home/Shinobi/videos"]
VOLUME ["/home/Shinobi/plugins"]
VOLUME ["/config"]
VOLUME ["/customAutoLoad"]

EXPOSE 8080

ENTRYPOINT ["/home/Shinobi/Docker/init.sh"]

CMD [ "pm2-docker", "pm2.yml" ]