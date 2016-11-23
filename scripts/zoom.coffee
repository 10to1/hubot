module.exports = (robot) ->
  robot.hear /!zoom/, (msg) ->
    msg.send "/zoom"

