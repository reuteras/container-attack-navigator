FROM node:latest

LABEL maintainer="Coding <code@ongoing.today>"

WORKDIR /nav-app/

# Install packages and build 
RUN git clone https://github.com/mitre-attack/attack-navigator.git && \
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
    npm install --unsafe-perm

CMD npm start

USER node
EXPOSE 4200
