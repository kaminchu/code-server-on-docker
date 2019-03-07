FROM node:8.15.0-jessie as builder

ENV CODE_VERSION 1.31.1-100

WORKDIR /work
RUN apt-get update && apt-get install -y git libxkbfile-dev libsecret-1-dev bash \
 && git clone --depth=1 -b ${CODE_VERSION} https://github.com/codercom/code-server.git \
 && cd code-server \
 && yarn self-update \
 && yarn install --network-concurrency 1 \
 && yarn task build:server:binary

FROM ubuntu:18.10
ENV CODE_USER=code CODE_PASSWORD=password

COPY --from=builder /work/code-server/packages/server/cli-linux-x64 /usr/local/bin/code-server

RUN apt-get update && apt-get install -y openssl net-tools sudo

RUN groupadd -g 1000 ${CODE_USER} \
 && useradd  -g ${CODE_USER} -G sudo -m -s /bin/bash ${CODE_USER} \
 && echo "${CODE_USER}:${CODE_PASSWORD}" | chpasswd \
 && echo 'Defaults visiblepw' >> /etc/sudoers \
 && echo "${CODE_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${CODE_USER}

WORKDIR /work
EXPOSE  8443
ENTRYPOINT ["code-server"]