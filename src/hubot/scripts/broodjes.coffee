# 10to1 broodjes maangement system
# 
# broodjes - Show the list of broodjes
# welke broodjes - Show the link to the price list
# voor mij geen broodje - Remove your order from today
# geen broodjes - Remove todays orders
# bestel een <broodje> - Order a broodje for today
# bestel alle broodjes - Send an order email to a la minute
#
sprintf = require('sprintf').sprintf

env = process.env

class Sandwicher

  constructor: (robot, msg) ->
    @robot = robot
    @msg = msg

  order_broodje_for_today: (user, broodje) ->
    @robot.brain.data.broodjes = {} unless @robot.brain.data.broodjes
    @robot.brain.data.broodjes[@today()] = {} unless @robot.brain.data.broodjes[@today()]
    @robot.brain.data.broodjes[@today()][user.id] = broodje
   

  broodjes_for_today: ->
    @robot.brain.data.broodjes = {} unless @robot.brain.data.broodjes
    @robot.brain.data.broodjes[@today()]

  no_broodjes_for_today: ->
    @robot.brain.data.broodjes = {} unless @robot.brain.data.broodjes
    @robot.brain.data.broodjes[@today()] = null

  no_broodje_for_today: (user) ->
    @robot.brain.data.broodjes = {} unless @robot.brain.data.broodjes
    @robot.brain.data.broodjes[@today()][user.id] = null

  today: ->
    date = new Date()
    DAY = 1000 * 60 * 60  * 24
    Math.round(date.getTime() / DAY)

module.exports = (robot) ->

  robot.respond /welke broodjes(\s+zijn er)?/i, (msg) ->
    msg.send "Geen idee! Hier is de link: http://www.alaminute.be/prijslijst.html"

  robot.respond /(vandaag\s+)?geen broodjes/i, (msg) ->
    sandwicher = new Sandwicher robot, msg
    broodjes = sandwicher.no_broodjes_for_today() 
    msg.send "Wa is dees? Maagden!"

  robot.respond /(voor\s+mij\s+)?geen broodje/i, (msg) ->
    sandwicher = new Sandwicher robot, msg
    broodjes = sandwicher.no_broodje_for_today(msg.message.user) 
    msg.send "Hoe? Geen broodje? Maaagd!"

  robot.respond /bestel een (.*)/i, (msg) ->
    if msg.match[1] == "clear"
      msg.send "Ge moet wel een broodje doorgeven hé maaagd!"
    else
      broodje = msg.match[1]
      sandwicher = new Sandwicher robot, msg
      sandwicher.order_broodje_for_today(msg.message.user, broodje)
      msg.send "#{msg.message.user.name} gaat straks een #{broodje} eten"

  robot.respond /broodjes/i, (msg) ->
    contains_broodjes = list_broodjes(msg)
    if !contains_broodjes
        msg.send "Er zijn nog geen broodjes ingegeven voor vandaag"

  robot.respond /bestel alle broodjes$/i, (msg) ->
    contains_broodjes = list_broodjes(msg)
    if contains_broodjes
        msg.send "Als je de mail wil versturen bevestig dan met dit command 'bestel alle broodjes!!'"
    else
        msg.send "Er moeten vandaag geen broodjes besteld worden!"

  robot.respond /bestel alle broodjes!!/i, (msg) ->
      nodemailer= require("nodemailer");
      nodemailer.SMTP = 
        host: 'smtp.gmail.com',
        port: 465,
        ssl: true,
        use_authentication: true,
        user: env.GMAIL_SCANNER_USER,
        pass: env.GMAIL_SCANNER_PASSWORD
      sandwicher = new Sandwicher robot, msg
      broodjes = sandwicher.broodjes_for_today() 
      formatted_broodjes = []
      for userid, broodje of broodjes
          if broodje != null
              formatted_broodjes.push 
                "broodje": broodje, 
                "name": robot.brain.data.users[userid].name
      if formatted_broodjes.length > 0
          msg.send "A la minute emailen..."
          text = "Bestelling voor 10to1\n\n---\n\nLeveradres: Prins Boudewijnlaan 5, 2550 Kontich\n"
          for broodje in formatted_broodjes
            text += "\n------------------------------------------------------------------------------------------\n" 
            text += sprintf("%-30.30s - %-50.50s", broodje["name"], broodje["broodje"])
          text += "\n-------------------------------------------------------------------------------------------\n" 
          nodemailer.send_mail
              to : env.BROODJES_EMAIL,
              sender : env.GMAIL_SCANNER_USER,
              subject : "Broodjes bestelling voor 10to1",
              body: text
              , (err, success) ->
                  if success?
                    msg.send "De broodjes zijn besteld! BOOYAH!"
                  else
                    msg.send err
      else
        msg.send "Er zijn geen broodjes ingegeven!"
    
  list_broodjes = (msg) ->
    sandwicher = new Sandwicher robot, msg
    broodjes = sandwicher.broodjes_for_today() 
    contains_broodjes = no
    for userid, broodje of broodjes
        if broodje == null
          contains_broodjes = no
        else
          contains_broodjes = yes
          msg.send "#{robot.brain.data.users[userid].name}: #{broodje}"
    return contains_broodjes
