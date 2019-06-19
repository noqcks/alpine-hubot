querystring = require 'querystring'

jenkinsBuild = (msg, job, options) ->
    url = process.env.HUBOT_JENKINS_URL
    params = Object.keys(options).map((k) -> "#{k}=#{options[k]}" ).join('&')
    path = "#{url}/job/#{job}/buildWithParameters?#{params}"

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
        else if 400 == res.statusCode
          jenkinsBuild(msg, true)
        else if 404 == res.statusCode
          msg.reply "Build not found, double check that it exists and is spelt correctly."
        else
          msg.reply "Jenkins says: Status #{res.statusCode} #{body}"

module.exports = (robot) ->
  robot.respond /push (.+)/i, (msg) ->
    buildconfigArray = msg.match[1].match(/\S+/g)
    buildconfig = {}
    buildconfigArray.map (val) ->
      k, v = val.split("=")
      buildconfig[k] = v
    jobsToBuild = []
    if buildconfig['node']
      options = {
        nodename: buildconfig['node'],
        hackerrank_branch:  buildconfig['backend'] || 'master',
        frontendcore_branch: buildconfig['frontend'] || 'master'
      }
      if buildconfig['node'] == 'workers'
        options = Object.assign(options, {
          workers: 'true',
          rba: 'true'
        })
      jenkinsBuild(msg, 'k8s-private', options)

      if buildconfig['sourcing']
        options = {
          nodename: buildconfig['node'],
          sourcing_branch:  buildconfig['sourcing'] || 'master',
        }
        jenkinsBuild(msg, 'k8s-private-sourcing', options)

      if buildconfig['candidate']
        options = {
          nodename: buildconfig['node'],
          candidate_branch:  buildconfig['candidate'] || 'master',
          namespace: buildconfig['namespace'] || buildconfig['node']
        }
        jenkinsBuild(msg, 'k8s-preprod-candidate-site', options)



