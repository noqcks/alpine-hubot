# dockbot

Putting hubot inside Docker.

## Testing

Pre-requisites:

- A slack token for your bot

To build a docker image

```
docker build -t dockbot .
```

To run the docker image

```
docker run -e HUBOT_SLACK_TOKEN=$slack_token -d dockbot
```

To see your docker logs, run `docker ps` and grab the ID of your bot container then run `docker logs $ID`.

## Adding Scripts


### External Scripts

Assuming your hubot script is called `hubot-foo`

1. `npm install --save hubot-foo`
2.  add `hubot-foo` to `hubot/external-scripts.json`

## Deployment

This is automatically deployed by travis-ci when on `dockbot/dockbot` and branch master.

The AWS access key id and secret needed to deploy are kept in travis-ci interface ENV variables.

## Environment Configuration

All the environment variables used to run dockbot are located in `.dockbot-env`. These can be loaded in elasticbeanstalk via `eb setenv KEY=value`.
