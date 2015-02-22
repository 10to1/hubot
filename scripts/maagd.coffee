module.exports = (robot) ->
  robot.hear /\bmaa+gd\b/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.reply "Zijde gij nog maagd of wat?"


