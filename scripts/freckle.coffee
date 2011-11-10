# Freckle integration for hubot
#
# my freckle token is <token>
# forget my freckle token
# what is my freckle token

module.exports = (robot) ->
  robot.respond /my freckle token is (.*)/i, (msg) ->
    robot.brain.data.freckle = {} unless robot.brain.data.freckle
    msg.send msg.message.user
    robot.brain.data.freckle[msg.message.user.name] = msg.match[1]
    msg.send 'Okay, I\'ll remember your freckle token.'

  robot.respond /forget my freckle token/i, (msg) ->
    robot.brain.data.freckle = {} unless robot.brain.data.freckle
    robot.brain.data.freckle[msg.message.user.name] = null
    msg.send 'Okay, I forgot your freckle token.'

  robot.respond /what\s+is\s+my\s+freckle\s+token\??/i, (msg) ->
    robot.brain.data.freckle = {} unless robot.brain.data.freckle
    freckle = robot.brain.data.freckle[msg.message.user.name]
    if freckle
      msg.send "Your freckle token in #{freckle}"
    else
      msg.send 'I don\'t know your freckle token.'
