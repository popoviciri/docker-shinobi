FROM node:slim

# ShinobiPro branch, defaults to dev
ARG APP_BRANCH=dev
#ARG APP_BRANCH_DEV=dashboard-v3

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

RUN apt update --fix-missing && apt upgrade -y
RUN \
    apt install -y \
        coreutils \
        wget \
        curl \
        net-tools \
        git \
        tar \
        sudo \
        xz-utils \
        procps \
        gnutls-bin \
        yasm \
        software-properties-common \
        apt-transport-https \
        gnupg \
        --no-install-recommends
RUN \
    apt install -y \
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
        x264 \
        --no-install-recommends
RUN \
    apt install -y \
        mariadb-client \
        --no-install-recommends

# install latest ffmpeg static build
#RUN curl -s -O https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz \
#    && tar xpf ./ffmpeg-git-amd64-static.tar.xz -C ./ \
#    && cp -f ./ffmpeg-git-*-amd64-static/ff* /usr/bin/ \
#    && chmod +x /usr/bin/ff* \
#    && rm -f ffmpeg-git-amd64-static.tar.xz \
#    && rm -rf ./ffmpeg-git-*-amd64-static

# install ffmpeg from jellyfin
RUN wget -O - https://repo.jellyfin.org/jellyfin_team.gpg.key | apt-key add - \
    && echo "deb [arch=amd64] https://repo.jellyfin.org/$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" | tee /etc/apt/sources.list.d/jellyfin.list \
    && apt update \
    && apt install --no-install-recommends --no-install-suggests -y \
    jellyfin-ffmpeg
ENV PATH=$PATH:/usr/lib/jellyfin-ffmpeg

# Assign working directory
WORKDIR /home/Shinobi

RUN git clone -b ${APP_BRANCH}  https://bitbucket.org/ShinobiSystems/shinobi.git /home/Shinobi
#RUN git -c user.email="email@domain" -c user.name="Merge before testing" merge origin/${APP_BRANCH_DEV}
RUN rm -rf /home/Shinobi/plugins
RUN rm -rf package-lock.json
RUN cp ./Docker/pm2.yml ./

RUN npm i npm@latest -g && \
    npm install --unsafe-perm
RUN npm install pm2 -g && \
    npm install mqtt

# Copy default configuration files
RUN chmod -f +x /home/Shinobi/Docker/init.sh

VOLUME ["/home/Shinobi/videos"]
VOLUME ["/home/Shinobi/plugins"]
VOLUME ["/config"]
VOLUME ["/home/Shinobi/libs/customAutoLoad"]

EXPOSE 8080

ENTRYPOINT ["/home/Shinobi/Docker/init.sh"]

CMD [ "pm2-docker", "pm2.yml" ]
