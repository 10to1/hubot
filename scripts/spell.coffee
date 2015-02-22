# Description
#   Adds amazing spell functionality to hubot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot spell <word> - Hubot will spel out the word in caps.
#
# Notes:
#   None
#
# Author:
#   pjaspers

module.exports = (robot) ->

  robot.respond /(spell)( me )?(.*)/i, (msg)->
    word = msg.match[3]
    msg.send spell(word)

  spell = (msg) ->
    (msg.split("").map (s) -> s.toUpperCase()).join("·")
