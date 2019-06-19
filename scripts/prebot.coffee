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
  robot.respond /push node=(.+)/i, (msg) ->
    options = {
      nodename: msg.match[1],
      hackerrank_branch: 'master',
      frontendcore_branch: 'master'
    }
    jenkinsBuild(msg, 'k8s-private', options)

