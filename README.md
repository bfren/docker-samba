# Samba

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-samba) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Fsamba) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Fsamba) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-samba/build.yml?branch=main)

[Docker Hub](https://hub.docker.com/r/bfren/samba) - [Quay.io](https://quay.io/repository/bfren/samba) - [bfren ecosystem](https://github.com/bfren/docker)

## Introduction

[Samba](https://www.samba.org) file server, sharing folders with Windows, macOS and Linux over SMB. Users and shares are defined in one JSON file, so there's no `smb.conf` to write.

It is built on [Alpine + S6](https://github.com/bfren/docker-alpine-s6), with Samba from Alpine's packages.

## Quickstart

`docker-compose.yml`:

```yaml
services:
  samba:
    image: quay.io/bfren/samba:3.2
    restart: unless-stopped
    ports:
      - "0.0.0.0:445:445"
    environment:
      - BF_SAMBA_UID=1000
    volumes:
      - ./v/shares.json:/files/shares.json:ro
      - ./v/docs:/files/docs
      - ./v/public:/files/public
```

`v/shares.json`:

```json
{
    "$schema": "https://schemas.bfren.dev/docker/samba/shares.json",
    "users": [
        { "name": "fred", "pass": "change-me" }
    ],
    "shares": [
        { "name": "docs", "comment": "Documents", "users": [ "fred" ] },
        { "name": "public", "users": [ "*" ] }
    ]
}
```

Run `docker compose up -d`, then connect to `\\<server>\docs` (Windows) or `smb://<server>/docs` (macOS / Linux) as `fred`. See `shares-conf-sample.json` for more.

## Features

* 📁 Users and shares defined in one JSON file, with a schema for validation and autocomplete
* 👥 Each share limited to its users, or open to guests
* 👤 Everything is written as one user, so files on the host have the owner you choose
* 🔒 SMB over TCP port 445 only
* 🩺 Health check that lists the shares
* 🧪 Built-in tests

## Tags

Images are published to Docker Hub (`bfren/samba`) and Quay.io (`quay.io/bfren/samba`) for `linux/amd64`, `linux/arm/v7` and `linux/arm64`, with Samba 4.23.8 on Alpine 3.24.

| Tag                  | Example           | Use when                                   |
| -------------------- | ----------------- | ------------------------------------------ |
| `latest`             |                   | You always want the newest image           |
| `MAJOR`              | `3`               | You want updates, but not breaking changes |
| `MINOR`              | `3.2`             | You want fixes only - **recommended**      |
| `VERSION`            | `3.2.0`           | You want to pin this image exactly         |
| `sambaX`, `sambaX.Y` | `samba4.23`       | You want a Samba version                   |
| `sambaX.Y.Z`         | `samba4.23.8`     | You want an exact Samba release            |
| `sambaX.Y-VERSION`   | `samba4.23-3.2.0` | You want to pin both                       |

## Configuration

### Ports

| Port  | Purpose      |
| ----- | ------------ |
| `445` | SMB over TCP |

### Volumes

| Volume   | Purpose                                                                 |
| -------- | ----------------------------------------------------------------------- |
| `/files` | `shares.json`, and a folder for each share - mount each one separately. |

### shares.json

`/files/shares.json` must exist - the container stops without it.

| Property | Description                                         |
| -------- | --------------------------------------------------- |
| `users`  | A list of users, each with a `name` and `pass`.     |
| `shares` | A list of shares, each shared from `/files/<name>`. |

| Share property | Description                                                               | Default |
| -------------- | ------------------------------------------------------------------------- | ------- |
| `name`         | **Required.** The share's name, and the folder in `/files` it shares.     |         |
| `comment`      | Description shown to clients.                                             |         |
| `users`        | Users who can access the share - or `[ "*" ]` for a public (guest) share. |         |
| `browseable`   | `false` to hide the share from share lists.                               | `true`  |
| `writeable`    | `false` to make the share read-only.                                      | `true`  |

Public shares are open to everyone who can reach the server, without a password, and are always browseable and writeable.

### Environment Variables

| Variable                 | Values | Description                                                                     | Default        |
| ------------------------ | ------ | ------------------------------------------------------------------------------- | -------------- |
| `BF_SAMBA_UID`           | number | UID that files are written as - set it to the owner of the folders on the host. | `1000`         |
| `BF_SAMBA_WORKGROUP`     | name   | Windows workgroup.                                                              | `WORKGROUP`    |
| `BF_SAMBA_SERVER`        | text   | Server description shown to clients.                                            | `Samba Server` |
| `BF_SAMBA_NETBIOS_ALIAS` | names  | Other names the server answers to.                                              |                |

See [Alpine + S6](https://github.com/bfren/docker-alpine-s6#environment-variables) for `BF_DEBUG`, `BF_TZ` and the other base image variables.

## How It Works

On every start:

1. A `samba` system user is created with `BF_SAMBA_UID` (if it doesn't exist yet).
2. Each user in `shares.json` that doesn't exist yet is created, with its Samba password.
3. `smb.conf` is generated, with a section for each share. Every share uses `force user = samba`, so whoever connects, files are created and changed as `samba`.

Then `smbd` runs under S6, logging to `docker logs`. The container stops if it crashes. Only `smbd` runs - there's no NetBIOS name service (`nmbd`), so the server may not appear when browsing the network: connect to it by name or address.

The health check (every 30 seconds) lists the shares as a guest, using SMB3.

## Testing

```sh
./test.nu   # builds the image and runs /test
./run.sh    # builds the image and opens a shell, using shares-conf-sample.json
```

`/test` runs this image's tests alongside the base images' tests: loading `shares.json`, generating each share (limited, public, browseable and writeable), the generated `smb.conf`, and the installed Samba version.

## Troubleshooting

### The container stops straight after starting

`/files/shares.json` is missing or isn't valid JSON - check `docker logs <container>`.

### I changed a password but the old one still works

Users are only created once, so changes to `pass` are ignored until the container is recreated (`docker compose up -d --force-recreate`). Or change it straight away with `docker exec -it <container> smbpasswd <name>`.

### Files on the host belong to the wrong user

Set `BF_SAMBA_UID` to the UID of the user who owns the folders on the host (`id -u`), then recreate the container.

### I can't see the server when browsing the network

There is no NetBIOS service - connect directly, e.g. `\\192.168.1.10\docs`.

## FAQs

### Can I use the same share for several users with different permissions?

Not within one share - create a separate share for each set of permissions.

## Licence

> [MIT](https://mit.bfren.dev/2022)

## Copyright

> Copyright (c) 2022-2026 [bfren](https://bfren.dev) (unless otherwise stated)
