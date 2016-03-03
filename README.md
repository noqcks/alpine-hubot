# alpine-hubot
[![Build Status](https://travis-ci.org/noqcks/alpine-hubot.svg?branch=master)](https://travis-ci.org/noqcks/alpine-hubot)

Putting hubot inside Docker.

## Testing

Pre-requisites:

- A slack token for your bot

To build a docker image

```
docker build -t alpine-hubot .
```

To run the docker image

```
docker run -e HUBOT_SLACK_TOKEN=$slack_token -d alpine-hubot
```

To see your docker logs, run `docker ps` and grab the ID of your bot container then run `docker logs $ID`.

## Adding Scripts


### External Scripts

Assuming your hubot script is called `hubot-foo`

1. `npm install --save hubot-foo`
2.  add `hubot-foo` to `hubot/external-scripts.json`

