module.exports = (robot) ->
  robot.respond /push node=(.*)/i, id: 'prebot.pushNode', (msg) ->
    nodeName = msg.match[1]
    msg.message.text = "jenkins build k8s-private&frontendcore_branch=master&hackerrank_branch=master&nodename=#{nodeName}"
    robot.jenkins.build(msg)
