# Docker Samba

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-samba) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fsamba) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fsamba) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-samba/dev.yml?branch=main)

[Docker Repository](https://hub.docker.com/r/bfren/samba) - [bfren ecosystem](https://github.com/bfren/docker)

Comes with Samba pre-installed, and creates config based on a json file (see shares-conf-sample.json).

## Contents

* [Ports](#ports)
* [Volumes](#volumes)
* [Usage](#usage)
* [Licence / Copyright](#licence)

## Ports

* 445

## Volumes

| Volume   | Purpose                          |
| -------- | -------------------------------- |
| `/files` | Contains the files to be shared. |

## Usage

Sample Docker Compose and shares.json files:

```yaml
# docker-compose.yml

version: "3.8"

services:
  samba:
    image: bfren/samba:latest
    container_name: samba
    restart: unless-stopped
    ports:
      - "0.0.0.0:445:445"
    volumes:
      - ./v/files/shares.json:/files/shares.json:ro
      - /data/share/example:/files/example
      - /data/share/another:/files/another
    networks:
      - samba

networks:
  samba:
    driver: bridge
    name: samba
```

https://github.com/bfren/docker-samba/blob/1ef5fa992ba96576db1707c550bb6750d6b5d1a4/shares-conf-sample.json#L1-L31

## Licence

> [MIT](https://mit.bfren.dev/2022)

## Copyright

> Copyright (c) 2022-2023 [bfren](https://bfren.dev) (unless otherwise stated)
