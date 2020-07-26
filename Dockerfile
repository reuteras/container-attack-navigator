FROM node:current-slim

LABEL maintainer="Coding <code@ongoing.today>"

WORKDIR /nav-app/
ENV DEBIAN_FRONTEND noninteractive

# Install packages and build

RUN apt-get update --fix-missing && \
    apt-get install -qqy --no-install-recommends \
        ca-certificates \
        git \
        wget && \
    git clone https://github.com/mitre-attack/attack-navigator.git && \
    mv attack-navigator/nav-app/* . && \
    rm -rf attack-navigator && \
    cd src/assets && \
    # Cache for offline use
    wget https://raw.githubusercontent.com/mitre/cti/master/enterprise-attack/enterprise-attack.json && \
    wget https://raw.githubusercontent.com/mitre/cti/master/mobile-attack/mobile-attack.json && \
    wget https://raw.githubusercontent.com/mitre/cti/master/pre-attack/pre-attack.json && \
    sed -i "s#https://raw.githubusercontent.com/mitre/cti/master/##" config.json && \
    sed -i "s#enterprise-attack#assets#" config.json && \
    sed -i "s#mobile-attack#assets#" config.json && \
    sed -i "s#pre-attack#assets#" config.json && \
    npm install --unsafe-perm && \
    apt remove -y git wget && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

CMD npm start

USER node
EXPOSE 4200
