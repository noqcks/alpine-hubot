# Wasimbot

Automating Wasim one script at a time.

## Testing

Pre-requisites:

- A name for your bot
- A slack token for your bot

To build a docker image

```
docker build -t $bot_name .
```

To run the docker image

```
docker run -e HUBOT_SLACK_TOKEN=$slack_token -d $bot_name
```

To see your docker logs, run `docker ps` and grab the ID of your bot container then run `docker logs $ID`.

## Adding Scripts

### External Scripts

Assuming your hubot script is called `hubot-foo`

1. `npm install --save hubot-foo`
2.  add `hubot-foo` to `hubot/external-scripts.json`

### Custom Scripts

-- TODO --

## Deployment

This is automatically deployed by travis-ci when on `telusdigital/wasimbot` and branch master.

The AWS access key id and secret needed to deploy are kept in travis-ci interface ENV variables.

## Environment Configuration

All the environment variables used to run wasimbot are located in `.wasimbot-env`. These can be loaded in elasticbeanstalk via `eb setenv KEY=value`.
