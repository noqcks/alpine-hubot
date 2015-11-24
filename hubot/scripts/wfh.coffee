# Description:
#   Have hubot keep track of working from home status
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot wfh <reason>
#   hubot notwfh
#   hubot why is <person> not here
#
#
# Author:
#   maschall

unknown_messages = [
  "I dunno ¯\_(ツ)_/¯",
  "They're swimming in garlic sauce ¯\_(ツ)_/¯"
]

module.exports = (robot) ->

  robot.respond /notwfh/i, (msg) ->
    msg.robot.brain.remove wfh_id(msg)

  robot.respond /wfh (.*)/i, (msg) ->
    wfh_message =
      message: msg.match[1]
      day: new Date

    msg.robot.brain.set wfh_id(msg), wfh_message
    msg.send "Got it!"

  robot.hear /why is (.*) not here/i, (msg) ->
    reason = msg.robot.brain.get ('wfh_' + msg.match[1])

    if reason? and ( reason.day.setHours(0,0,0,0) == ((new Date).setHours(0,0,0,0)) )
      msg.send reason.message
    else
      msg.send msg.random(unknown_messages)

wfh_id = (msg) ->
  'wfh_@' + msg.envelope.user.mention_name
