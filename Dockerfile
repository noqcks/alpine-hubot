FROM alpine

# MAINTAINER Ajish Balakrishnan <ajish@hackerrank.com>
MAINTAINER Devops <devops@hackerrank.com>

# Install dependencies
# For line 14: https://github.com/nodejs/docker-node/issues/813#issuecomment-407339011
RUN apk update && apk upgrade \
  && apk add --update busybox-suid \
  build-base automake git openssh \
  redis nodejs nodejs-npm python curl \
  && npm config set unsafe-perm true \
  && curl -sS https://bootstrap.pypa.io/get-pip.py | python \
  && pip install awscli \
  && npm install -g npm coffee-script yo generator-hubot \
  && apk --purge -v del py-pip \
  && rm -rf /var/cache/apk/* \
  && adduser -h /hubot -s /bin/bash -S hubot

# Create hubot user
USER  hubot
WORKDIR /hubot

ADD package.json \ 
    hubot/hubot-scripts.json \
    hubot/external-scripts.json \
    /hubot/

RUN yo hubot --owner="DevOps <devops@hackerrank.com>" \
    --name="prebot" --description="Hackzoid's friend in pre-prod world" \
    --defaults && \
    npm install

# Overwriting start script https://github.com/noqcks/alpine-hubot/issues/2
ADD bin/hubot bin/
ADD scripts/ scripts/

EXPOSE 80
