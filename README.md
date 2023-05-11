# Docker Samba

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-samba) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fsamba) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fsamba) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-samba/dev.yml?branch=main)

[Docker Repository](https://hub.docker.com/r/bfren/samba) - [bfren ecosystem](https://github.com/bfren/docker)

Comes with Samba pre-installed, and creates config based on a json file (see shares-conf-sample.json).

## Contents

* [Ports](#ports)
* [Volumes](#volumes)
* [Sample Files](#sample-files)
* [Licence / Copyright](#licence)

## Ports

* 445

## Volumes

| Volume   | Purpose                          |
| -------- | -------------------------------- |
| `/files` | Contains the files to be shared. |

## Sample Files

docker-compose.yml

```yaml
version: "3.8"

services:
  samba:
    image: bfren/samba:latest
    container_name: samba
    restart: unless-stopped
    ports:
      - "0.0.0.0:445:445"
    volumes:
      - ./v/shares.json:/files/shares.json:ro
      - ./v/example:/files/example
      - ./v/another:/files/another
    networks:
      - samba

networks:
  samba:
    driver: bridge
    name: samba
```

shares.json

```json
{
    "$schema": "https://schemas.bfren.dev/docker/samba/shares.json",
    "users": [
        {
            "name": "fred",
            "pass": "password"
        },
        {
            "name": "jones",
            "pass": "another"
        }
    ],
    "shares": [
        {
            "name": "example",
            "comment": "Optional description of share",
            "users": [
                "fred"
            ],
            "browseable": false,
            "writeable": false
        },
        {
            "name": "another",
            "users": [
                "fred",
                "jones"
            ]
        }
    ]
}
```

## Licence

> [MIT](https://mit.bfren.dev/2022)

## Copyright

> Copyright (c) 2022-2023 [bfren](https://bfren.dev) (unless otherwise stated)
