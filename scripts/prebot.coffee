querystring = require 'querystring'

jenkinsBuild = (msg, job, options = {}) ->
    url = process.env.HUBOT_JENKINS_URL
    path = "#{url}/job/#{job}/"
    params = Object.keys(options).map((k) -> "#{k}=#{options[k]}" ).join('&')
    if !!params
      path += "buildWithParameters?#{params}"
    else
      path += "build"

    req = msg.http(path)

    if process.env.HUBOT_JENKINS_AUTH
      auth = new Buffer(process.env.HUBOT_JENKINS_AUTH).toString('base64')
      req.headers Authorization: "Basic #{auth}"

    req.header('Content-Length', 0)
    req.post() (err, res, body) ->
        if err
          msg.reply "Jenkins says: #{err}"
        else if 200 <= res.statusCode < 400 # Or, not an error code.
          msg.reply "(#{res.statusCode}) Build started for #{job} #{url}/job/#{job}"
        else if 404 == res.statusCode
          msg.reply "Build not found, double check that it exists and is spelt correctly."
        else
          msg.reply "Jenkins says: Status #{res.statusCode} #{body}"

module.exports = (robot) ->
  Redis = require('redis')
  cronJob = require('cron').CronJob
  client = Redis.createClient('6379', 'redis')

  purgeExpiredNamespaces = ->
    http = require('http');
    auth = new Buffer(process.env.HUBOT_JENKINS_AUTH).toString('base64')
    client.zrangebyscore 'live-namespaces', '-inf', (new Date()).getTime(), (e, items) ->
      return if items.length < 1
      robot.messageRoom 'CKPA1M0A3', "Removing #{items}"
      options = {
        host: 'jenkins.hackerrank.link',
        port: 8080,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': "Basic #{auth}"
        }
      }
      items.forEach (item) ->
        [service, nodename] = item.split("::")
        options['path'] = "/job/private-node-cleanup/buildWithParameters?nodename=#{nodename}&hackerrank=#{service == 'hackerrank'}&sourcing=#{service == 'sourcing'}&content=#{service == 'content'}"
        req = http.request options, (res) ->
          client.zrem('live-namespaces', item)
          console.log('Status: ' + res.statusCode)
          console.log('Headers: ' + JSON.stringify(res.headers))
          res.setEncoding('utf8')
          res.on 'data', (body) ->
            console.log('Body: ' + body)

        req.on 'error', (e) ->
          console.log('problem with request: ' + e.message);

        req.end()

  new cronJob('00 */5 * * * *', purgeExpiredNamespaces, null, true)


  robot.respond /deploy qa/i, (msg) ->
    jenkinsBuild(msg, 'create-qa-test-branch', {'TRIGGERING_USER': msg.envelope.user.name})

  robot.respond /(push|patch) (.+)/i, (msg) ->
    action = msg.match[1]
    buildconfigArray = msg.match[2].match(/\S+/g)
    buildconfig = {}
    buildconfigArray.map (val) ->
      [k, v] = val.split("=")
      buildconfig[k] = v
    expiryTime = (new Date()).getTime() + ((buildconfig['ttl'] || 48) * 60 * 60 * 1000)
    jobsToBuild = []
    if buildconfig['node']
      options = {
        nodename: buildconfig['node'],
        hackerrank_branch:  buildconfig['backend'] || 'master',
        frontendcore_branch: buildconfig['frontend'] || 'master'
        ops_branch: buildconfig['ops'] || 'master'
        rba: buildconfig['rba'] || 'false'
        railsDebug: buildconfig['railsDebug'] || 'false'
        nodeDebug: buildconfig['nodeDebug'] || 'false'
      }
      if buildconfig['node'] == 'workers'
        options = Object.assign(options, {
          workers: 'true',
          rba: 'true'
        })
      if action != 'patch' || !buildconfig['sourcing']
        jenkinsBuild(msg, 'k8s-private', options)
        client.zadd("live-namespaces", expiryTime, "hackerrank::#{buildconfig['node']}")

      if buildconfig['sourcing']
        options = {
          nodename: buildconfig['node'],
          sourcing_branch:  buildconfig['sourcing'] || 'master'
        }
        if action != 'patch' || !buildconfig['hackerrank_branch']
          jenkinsBuild(msg, 'k8s-private-sourcing', options)
          client.zadd("live-namespaces", expiryTime, "sourcing::#{buildconfig['node']}")

      if buildconfig['candidate']
        options = {
          nodename: buildconfig['node'],
          branch:  buildconfig['candidate'],
          namespace: buildconfig['namespace'] || buildconfig['node'],
          ops_branch: buildconfig['ops'] || 'master'
        }
        jenkinsBuild(msg, 'k8s-preprod-candidate-site', options)

      if buildconfig['content']
        options = {
          nodename: buildconfig['node'],
          content_branch:  buildconfig['content'] || 'master',
          namespace: buildconfig['namespace'] || buildconfig['node']
          ops_branch: buildconfig['ops'] || 'master'
        }
        client.zadd("live-namespaces", expiryTime, "content::#{buildconfig['node']}")
        jenkinsBuild(msg, 'k8s-private-content', options)



