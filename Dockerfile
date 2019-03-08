FROM node:8.15.0-alpine as builder

WORKDIR /work
RUN apk add --update --no-cache git libxkbfile libsecret \
 && git clone https://github.com/codercom/code-server.git \
 && cd code-server \
 && npm install -g yarn@1.13.0 \
 && yarn install \
 && yarn task build:server:binary

FROM ubuntu:18.10
ENV LANG=en_US.UTF-8

ARG CODE_USER=code
ARG CODE_PASSWORD=password

COPY --from=builder /work/code-server/packages/server/cli-linux-x64 /usr/local/bin/code-server

RUN apt-get update && apt-get install -y openssl net-tools sudo locales \
 && locale-gen en_US.UTF-8

RUN groupadd -g 1000 ${CODE_USER} \
 && useradd  -g ${CODE_USER} -G sudo -m -s /bin/bash ${CODE_USER} \
 && echo "${CODE_USER}:${CODE_PASSWORD}" | chpasswd \
 && echo 'Defaults visiblepw' >> /etc/sudoers \
 && echo "${CODE_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${CODE_USER}

WORKDIR /work
EXPOSE  8443
ENTRYPOINT ["code-server"]
