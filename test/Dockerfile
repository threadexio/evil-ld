FROM docker.io/debian:latest

ENV DEBIAN_FRONTEND noninteractive

RUN set -eu;\
  apt-get update -y;\
  apt-get install -y \
    tmux moreutils file \
    gcc gcc-multilib make patchelf \
    gdb strace

RUN mkdir -p /shared
WORKDIR /shared

ENTRYPOINT ["/usr/bin/tmux"]
