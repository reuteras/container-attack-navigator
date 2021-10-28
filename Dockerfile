FROM node:16-buster-slim as build-env

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
    cd ../.. && \
    npm install --unsafe-perm && \
    npm install -g @angular/cli && \
    ng build --output-path /tmp/output && \
    rm -rf /var/lib/apt/lists/*

USER node
EXPOSE 4200

# Build final container to serve static content.
FROM nginx:mainline-alpine
COPY --from=build-env /tmp/output /usr/share/nginx/html

