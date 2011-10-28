module.exports = (robot) ->
  robot.hear /^maa+gd[!.]*$/, (msg) ->
    setTimeout (() -> msg.reply "Zijde gij nog maagd of wat?"), 2000


