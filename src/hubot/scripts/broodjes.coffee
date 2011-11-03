# 10to1 broodjes maangement system
# 
# broodjes - Show the list of broodjes
# welke broodjes - Show the link to the price list
# voor mij geen broodje - Remove your order from today
# geen broodjes - Remove todays orders
# bestel een <broodje> - Order a broodje for today
#

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
    sandwicher = new Sandwicher robot, msg
    broodjes = sandwicher.broodjes_for_today() 
    contains_broodjes = no
    for userid, broodje of broodjes
        if broodje == null
          contains_broodjes = no
        else
          contains_broodjes = yes
          msg.send "#{robot.brain.data.users[userid].name}: #{broodje}"

    if !contains_broodjes
        msg.send "Stop @tom, we moeten vandaag geen broodjes hebben!"
