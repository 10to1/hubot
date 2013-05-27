# Description:
#   Will display a movie about Snelle Jelle
#   For example:
#         bla ende blabla snelle jelle bla
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#
#   ... snelle jelle ...
#
# Author:
#   pjaspers
#
module.exports = (robot) ->
  robot.hear /snelle jelle/i, (msg) ->
    movies = [
      "http://www.youtube.com/watch?v=6LmROvCaeOg",
      "http://www.youtube.com/watch?v=A7xNh2iAKAY",
      "http://www.youtube.com/watch?v=JGpO9uluXy8",
      "http://www.youtube.com/watch?v=CSAnd3ffvk4"
    ]
    if msg.message.user.name != "HUBOT"
      msg.send movies[Math.floor(Math.random() * movies.length)]
