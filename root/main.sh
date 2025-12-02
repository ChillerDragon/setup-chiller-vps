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

if [ ! -f ~/.ssh/known_hosts ]
then
	mkdir -p ~/.ssh
	cat <<-EOF > ~/.ssh/known_hosts
	# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
	github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
	github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
	github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=

	EOF
	printf '[*] added github.com to known hosts .. OK\n'
fi

[ -f ./root/packages.sh ] && cd ./root

if [ ! -x "$(command -v cstd)" ]
then
	printf '[*] installing cstd ..\n'
	wget -O /usr/local/bin/cstd https://paste.zillyhuhn.com/0 && chmod +x /usr/local/bin/cstd
fi

./etc_hosts.sh
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

