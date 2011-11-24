module.exports = (robot) ->
  robot.hear /(piet|junkiesxl)/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.reply sloganize("Piet", "wining")

  robot.hear /(jelle|verbeeckx|fousa|jaakske)/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.reply sloganize("Jelle", "being awesome")

  robot.hear /(bob|bab|bib)/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.reply sloganize("Bob", "growing hair")

sloganize = (name, slogan) ->
    "#{name}'s the name, #{slogan}'s the game!"
