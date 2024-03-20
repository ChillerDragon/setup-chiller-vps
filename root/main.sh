#!/bin/bash

set -euo pipefail

# shellcheck disable=1091
[ -f ./../.env ] && source ./../.env

# shellcheck disable=1091
[ -f ./.env ] && source ./.env

if [ "$SSH_PORT" = "" ]
then
  printf 'enter your ssh port:\n'
  read -e -r -p '> ' SSH_PORT
fi
if [ "$SSH_PUBLIC_KEY" = "" ]
then
  printf 'enter your ssh public key:\n'
  read -e -r -p '> ' SSH_PUBLIC_KEY
fi

if [ ! -f /root/.ssh/authorized_keys ]
then
  mkdir -p /root/.ssh
  printf '%s\n' "$SSH_PUBLIC_KEY" >> /root/.ssh/authorized_keys
fi

[ -f ./root/packages.sh ] && cd ./root

./packages.sh
./minimal_dotfiles.sh
./user.sh "$SSH_PUBLIC_KEY"
./harden_filesystem.sh
./harden_proc.sh
./harden_ssh.sh "$SSH_PORT"
./firewall.sh "$SSH_PORT"
./user_tools.sh chiller
./user_tools.sh teeworlds
./harden_limits.sh

