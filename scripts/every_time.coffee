# Description:
#   Every (Fucking) Time, someone says Every (Fucking) Time, hubot will display
#   an easy visual aid.
#   For example:
#         Every Fucking Time
#         => http://i.imgur.com/BCDGfuq.jpg
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#
#  Every. Fucking. Time.
#
# Author:
#   pjaspers
#

module.exports = (robot) ->
  robot.hear /every(\.|\s)*(fucking(\.|\s)+)*time(\.|\s)*/i, (msg) ->
    msg.send "http://i.imgur.com/BCDGfuq.jpg"