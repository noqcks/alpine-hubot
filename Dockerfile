FROM alpine

MAINTAINER Ben Visser <benny@noqcks.io>

# Install dependencies
RUN apk update && apk upgrade \
  && apk add redis \
  && apk add --update nodejs nodejs-npm \
  && apk add python \
  && apk add curl \
  && curl -sS https://bootstrap.pypa.io/get-pip.py | python \
  && pip install awscli \
  && npm install -g npm \
  && npm install -g coffee-script \
  && npm install -g yo generator-hubot \
  && apk --purge -v del py-pip \
  && rm -rf /var/cache/apk/*

# Create hubot user
RUN adduser -h /hubot -s /bin/bash -S hubot
USER  hubot
WORKDIR /hubot

# Install hubot
RUN yo hubot --owner="Ben Visser <benny@noqcks.io>" --name="dockbot" --description="Roll, roll, rollercoaster" --defaults
COPY package.json package.json
RUN npm install
ADD hubot/hubot-scripts.json /hubot/
ADD hubot/external-scripts.json /hubot/

# Overwriting start script https://github.com/noqcks/alpine-hubot/issues/2
ADD bin/hubot bin/ 

EXPOSE 80

# And go
ENTRYPOINT ["/bin/sh", "-c", "bin/hubot --adapter slack"]
