module.exports = (robot) ->
  robot.hear /(piet|junkiesxl)!/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.send sloganize("Piet", "winning")

  robot.hear /(inferis|geknipt|dotter|dottom|a3|maaagd)!/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.send sloganize("Dotter", "not being here")

  robot.hear /(jelle|verbeeckx|fousa|jaakske)!/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.send sloganize("Jelle", "being awesome")

  robot.hear /(bob|bab|bib|boob)!/, (msg) ->
    if msg.message.user.name != "HUBOT"
      msg.send sloganize("Bob", "growing hair")

sloganize = (name, slogan) ->
    "#{name}'s the name, #{slogan}'s the game!"
