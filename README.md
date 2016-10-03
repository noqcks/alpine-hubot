# hewbot-docker
[![Build Status](https://travis-ci.org/Dynamictivity/hewbot-docker.svg?branch=master)](https://travis-ci.org/noqcks/Dynamictivity/hewbot-docker)

Putting hubot inside Docker.

## Testing

Pre-requisites:

- A slack token for your bot

To build a docker image

```
docker build -t hewbot-docker .
```

To run the docker image

```
docker run -e HUBOT_SLACK_TOKEN=XXXXXX -d hewbot-docker
```

To see your docker logs, run `docker ps` and grab the ID of your bot container then run `docker logs $ID`.

## Adding Scripts


### External Scripts

Assuming your hubot script is called `hubot-foo`

- add `hubot-foo` to `hubot/external-scripts.json`

