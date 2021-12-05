[![dockerhub](https://github.com/popoviciri/docker-shinobi/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/popoviciri/docker-shinobi/actions/workflows/docker-publish.yml)
# docker-shinobi
based on debian-slim:
- build from latest DEV branch: https://gitlab.com/Shinobi-Systems/Shinobi/-/tree/dev
- with latest ffmpeg static builds: https://johnvansickle.com/ffmpeg/
- no mysql server

# example docker-compose.yml
```
version: '3.9'

services:

#--------------------------------------------------------------- #
### Shinobi
# -------------------------------------------------------------- #
  shinobi:
    image: popoviciri/docker-shinobi
    container_name: shinobi
    restart: always
    ports:
      - 1337:1337
      - 80:8080
    environment:
      - DB_DISABLE_INCLUDED=true
      - DB_HOST=mariadb
      - DB_PORT=3306
      - TZ=Europe/Amsterdam
      - DB_DATABASE=shinobidb
      - DB_USER=shinobiuser
      - DB_PASSWORD=shinobipass
    volumes:
      - ./data/Shinobi/config:/config
      - ./data/Shinobi/plugins:/home/Shinobi/plugins
      - ./data/Shinobi/modules:/home/Shinobi/libs/customAutoLoad
      - /media/cameras:/home/Shinobi/videos
      - /dev/shm/shinobiDockerTemp:/dev/shm/streams
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    depends_on:
      - mariadb
    networks:
      - netdb
      - webproxy

#--------------------------------------------------------------- #
### mariadb
# -------------------------------------------------------------- #
# mariadb
  mariadb:
    image: mariadb
    container_name: mariadb
    restart: always
    expose:
      - 3306
    command:
      - --transaction-isolation=READ-COMMITTED
      - --binlog-format=ROW
    volumes:
      - ./data/mariadb:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=mariadbpass
      - TZ=Europe/Amsterdam
    networks:
      - netdb

# adminer
  adminer:
    image: adminer
    container_name: adminer
    restart: always
    ports:
      - 8080:8080
    environment:
      - ADMINER_DEFAULT_SERVER=mariadb
      - ADMINER_DESIGN='nette'
    depends_on:
      - mariadb
    command: php -S 0.0.0.0:8080 -t /var/www/html
    networks:
      - webproxy
      - netdb

##################################################################

networks:
  webproxy:
    name: webproxy
  netdb:
    name: netdb
```
