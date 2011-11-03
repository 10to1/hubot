module.exports = (robot) ->
  robot.hear /\bmaa+gd\b/, (msg) ->
    setTimeout (() -> msg.reply "Zijde gij nog maagd of wat?"), 2000


