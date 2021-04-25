# lgsm-packer

This repository contains Packer templates and provision scripts for [LGSM](https://github.com/GameServerManagers/LinuxGSM) game servers. I've seen a lot of implementations of game servers in Docker containers, tutorials showing how to host a server on your local machine, and so on. LGSM is great, but I found when trying to deploy a server you're left to fend for yourself for the most part. This repo aims to be a one-stop-shop for packaging and deploying LGSM game servers.

The beauty of Packer is that we only have to write the provision steps once, and they can be applied virtually anywhere. With the magic of parallel builds, multiple images can be generated simultaneously for which ever cloud provider / container solution you'd like, and you can even limit which images are built using the `-only` flag when building.

LGSM covers a wide variety of game servers, each with their own requirements and additional configurations. To manage this, I've created a single Packer template file that can be used to generate images based on game and on the target architecture you need.

To use this template, you can run the following to set the architecture and game you want to build for:

> packer build -only "\*ARCH" -var "game=GAME" lgsm.pkr.hcl

where `*ARCH` is the architecture to build for, preceded by a `*`, and `GAME` is the game server you want to install, following LGSM's game server naming scheme.

The following architectures and games are currently supported - the architecture and game names are listed along side their respective options.

### Architectures

-   AWS AMIs | `aws`
-   Docker images | `docker`
-   Linode | `linode`

### Games

-   Ark: Survival Evolved | `arkserver`
-   Don't Starve Together | `dstserver`
-   Minecraft Bedrock | `mcbserver`
-   Mordhau | `mhserver`
-   Terraria | `terrariaserver`
-   Valheim | `vhserver`

## Example

To install Minecraft Bedrock in a Docker container, you would run

> packer build -only "\*docker" -var "game=mcbserver" lgsm.pkr.hcl

If you want to build all architectures at once, omit the `-only` flag. I would not recommend.

## How Does This Work?

Every game first installs SteamCMD using the `install_steamcmd.sh` script. Not all game servers require this, however, the majority do.

Next, Node.js is installed for [GameDig](https://www.npmjs.com/package/gamedig) support with the `install_nodejs.sh` script. Again, not all games require this, however, many do.

Game specific requirements are installed with their respective `GAME.sh` script. This script installs all the necessary packages / dependencies for the specific game.

Finally, the LGSM specific install is installed with `GAME_lgsm.sh`. This script handles setting up the cron jobs and other LGSM business.

## Adding More Games & Architectures

Adding additional games is relatively easy: game specific requirements can be added with a new `GAME.sh` script. LGSM specific requirements can be added with a new `GAME_lgsm.sh` script.

These games are included because I play them. If there's an LGSM compatible game you'd like included, raise an issue or pull in a pull request.

New architectures can be added as new `source`'s. Ubuntu 20.04 is the common starting point for all the game servers for compatibility reasons.

I've only added AWS AMI's & Docker as of now because those are the only platforms I use. Feel free to raise an issue or pull in a pull request if you have a different cloud provider.
