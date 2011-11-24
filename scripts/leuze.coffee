module.exports = (robot) ->
  robot.hear /\b(piet|junkiesxl)\b/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.send sloganize("Piet", "wining")

  robot.hear /\b(jelle|verbeeckx|fousa|jaakske)\b/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.send sloganize("Jelle", "being awesome")

  robot.hear /\b(bob|bab|bib)\b/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.send sloganize("Bob", "growing hair")

sloganize = (name, slogan) ->
    "#{name}'s the name, #{slogan}'s the game!"
