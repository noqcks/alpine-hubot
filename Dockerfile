FROM ubuntu
MAINTAINER Ben Visser <benjamin.visser@telus.com>

RUN apt-get update
RUN apt-get -y install expect redis-server nodejs npm

RUN apt-get update && \
    apt-get install -y python-pip && \
    pip install awscli

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install -g coffee-script
RUN npm install -g yo generator-hubot

# Create hubot user
RUN useradd -d /hubot -m -s /bin/bash -U hubot

# Log in as hubot user and change directory
USER  hubot
WORKDIR /hubot

# Install hubot
RUN yo hubot --owner="Ben Visser <benjamin.visser@telus.com>" --name="wasimbot" --description="Roll, roll, rollercoaster" --defaults

# Some adapters / scripts
USER root
COPY package.json /src/package.json
RUN cd /src; npm install
USER hubot

# Activate some built-in scripts
ADD hubot/hubot-scripts.json /hubot/
ADD hubot/external-scripts.json /hubot/

RUN npm install cheerio --save && npm install
# ADD hubot/scripts/hubot-lunch.coffee /hubot/scripts/

# And go
CMD ["/bin/sh", "-c", "aws s3 cp --region eu-west-1 s3://telusdigital-secrets/hubot-env.sh .; . ./env.sh; bin/hubot --adapter slack"]
