FROM ubuntu:18.04 as builder

ARG CODE_VERSION=1.31.1-100

WORKDIR /work
RUN apt-get update && apt-get install -y tar wget \
 && wget https://github.com/codercom/code-server/releases/download/${CODE_VERSION}/code-server-${CODE_VERSION}-linux-x64.tar.gz \
 && tar xvzf code-server-${CODE_VERSION}-linux-x64.tar.gz \
 && cp code-server-${CODE_VERSION}-linux-x64/code-server /work/

FROM ubuntu:18.10
ENV LANG=en_US.UTF-8

ARG CODE_USER=code
ARG CODE_PASSWORD=password

COPY --from=builder /work/code-server /usr/local/bin/

RUN apt-get update \
 && apt-get install -y openssl net-tools sudo locales git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

RUN groupadd -g 1000 ${CODE_USER} \
 && useradd  -g ${CODE_USER} -G sudo -m -s /bin/bash ${CODE_USER} \
 && echo "${CODE_USER}:${CODE_PASSWORD}" | chpasswd \
 && echo 'Defaults visiblepw' >> /etc/sudoers \
 && echo "${CODE_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${CODE_USER}

WORKDIR /home/${CODE_USER}/work
EXPOSE  8443
ENTRYPOINT ["code-server"]
