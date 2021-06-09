# docker-cheesy-parts

Docker image packaging for [cheesy-parts](https://github.com/Team254/cheesy-parts).

# How to use this image

This image depends on MySQL, and requires some environment variables (below).

The image can be built and run with:

```shell
docker build --tag argonauts/cheesy-parts .

docker run \
    --publish 9000:9000 \
    --env MYSQL_DATABASE=cheesy_parts \
    --env MYSQL_USER=team254 \
    --env MYSQL_PASSWORD=correcthorsebatterystaple \
    argonauts/cheesy-parts
```

## Environment variables

The following environment variables can be configured:

- `PORT`: HTTP port
- `MYSQL_HOST`: MySQL hostname (default: `localhost`)
- `MYSQL_DATABASE`: MySQL database name
- `MYSQL_USER`: MySQL username
- `MYSQL_PASSWORD`: MySQL password

## Docker Compose

The easiest way to run this image with MySQL is with [Docker Compose](https://docs.docker.com/compose/):

```shell
mkdir mysql

docker compose up --build
```

Edit [docker-compose.yml](./docker-compose.yml) to change the MySQL credentials.

The MySQL data directory is mounted to `./mysql` by default.

## Hosting with Heroku

[Heroku](https://www.heroku.com/) is an easy and typically free way to host web applications, including the database. At the root of this project is a setup script [`heroku.sh`](./heroku.sh) that can do all the app setup needed:

```shell
./heroku.sh <app_name>
```

# License

This project is under the [GNU Generic Public License v3](https://github.com/emmercm/docker-qbittorrent/blob/master/LICENSE) to allow free use while ensuring it stays open.
