FROM node:16-buster-slim as build-env

LABEL maintainer="Coding <code@ongoing.today>"

WORKDIR /nav-app/
ENV DEBIAN_FRONTEND noninteractive

COPY offline.sh /offline.sh

# Install packages and build

RUN apt-get update --fix-missing && \
    apt-get install -qqy --no-install-recommends \
        ca-certificates \
        git \
        wget && \
    git clone https://github.com/mitre-attack/attack-navigator.git && \
    mv attack-navigator/nav-app/* . && \
    cd src/assets && \
    sh /offline.sh && \
    cd ../.. && \
    npm install --unsafe-perm && \
    npm install -g @angular/cli && \
    ng build --output-path /tmp/output && \
    rm -rf /var/lib/apt/lists/*

USER node

# Build final container to serve static content.
FROM nginx:mainline-alpine
COPY --from=build-env /tmp/output /usr/share/nginx/html

