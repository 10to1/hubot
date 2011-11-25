# 10to1 broodjes maangement system
#
# broodjes - Show the list of broodjes
# welke broodjes - Show the link to the price list
# voor mij geen broodje - Remove your order from today
# geen broodjes - Remove todays orders
# bestel een <broodje> - Order a broodje for today
# bestel alle broodjes - Send an order email to a la minute
#
module.exports = (robot) ->

  robot.respond /welke\s+broodjes(?:\s+zijn\s+er)?\??/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.show_list_of_broodjes()

  robot.respond /(vandaag\s+)?geen broodjes/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.remove_all_broodjes_for_today()

  robot.respond /voor\s+(.+?)\s+geen\s+broodje|geen\s+broodje\s+voor\s+(.+?)?/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.remove_broodje_for_today msg.match[1] ? msg.match[2]

  # test: http://www.rubular.com/r/yAApRvQH5D
  robot.respond /(doe|voor|bestel|bespreek|bezorg|ontbiedt|reserveer|eis|onderspreek)(?:(?:\s+voor)?\s+((?!(?:ne|een)).*?))?(\s+maa?r?)?(\s+een\s+|\s+ne\s+)(.*)/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.order_broodje_for_today msg.match[2], msg.match[5]

  robot.respond /broodjes/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.show_all_broodjes()

  robot.respond /bestel(?:\s+alle)?\s+broodjes(!!!?)?$/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.order_all_broodjes msg.match[1]?


#############################################


sprintf = require('sprintf').sprintf
env     = process.env

class SandwichBrain
  constructor: (robot, msg) ->
    @robot = robot
    @msg = msg

  order_broodje_for_today: (user, broodje) ->
    @robot.brain.data.broodjes = {} unless @robot.brain.data.broodjes
    @robot.brain.data.broodjes[@today()] = {} unless @robot.brain.data.broodjes[@today()]
    @robot.brain.data.broodjes[@today()][user] = broodje

  broodjes_for_today: ->
    @robot.brain.data.broodjes = {} unless @robot.brain.data.broodjes
    @robot.brain.data.broodjes[@today()]

  no_broodjes_for_today: ->
    @robot.brain.data.broodjes = {} unless @robot.brain.data.broodjes
    @robot.brain.data.broodjes[@today()] = null

  no_broodje_for_today: (user) ->
    @robot.brain.data.broodjes = {} unless @robot.brain.data.broodjes
    was = @robot.brain.data.broodjes[@today()][user]
    @robot.brain.data.broodjes[@today()][user] = null
    return was

  today: ->
    date = new Date()
    DAY = 1000 * 60 * 60  * 24
    Math.round(date.getTime() / DAY)

class Sandwicher
  constructor: (robot, msg) ->
    @robot = robot
    @msg = msg

  show_list_of_broodjes: ->
    @msg.send "Geen idee! Hier is de link: http://www.alaminute.be/prijslijst.html"

  remove_all_broodjes_for_today: ->
    brain = new SandwichBrain @robot, @msg
    broodjes = brain.broodjes_for_today()

    @msg.send "Wa is dees? Geen broodjes voor ulle, ja. Maagden!"

    contains_broodjes = no
    for name, broodje of broodjes
        if broodje != null
          contains_broodjes = yes
          @msg.send "Hey #{name}, uw broodje is geannuleerd! #fdj"

    brain.no_broodjes_for_today()

  remove_broodje_for_today: (name) ->
    brain = new SandwichBrain @robot, @msg
    name = @_fix_name name
    ok = brain.no_broodje_for_today(name)
    if ok?
      @msg.send "Allez dan, geen broodje voor #{name}. Maaagd!"
    else
      @msg.send "Jonge, #{name} heeft wel niks besteld he! Maaagd!"

  order_broodje_for_today: (name, broodje) ->
    brain = new SandwichBrain @robot, @msg
    name = @_fix_name name 
    brain.order_broodje_for_today(name, broodje)
    if name == @msg.message.user.name
      @msg.send "#{@msg.message.user.name} gaat straks een #{broodje} eten"
    else
      @msg.send "#{@msg.message.user.name} zorgt ervoor dat #{name} straks een #{broodje} kan eten"

  show_all_broodjes: ->
    brain = new SandwichBrain @robot, @msg
    broodjes = brain.broodjes_for_today()
    contains_broodjes = no
    for name, broodje of broodjes
        if broodje?
          contains_broodjes = yes
          @msg.send "#{name}: #{broodje}"

    if !contains_broodjes
        @msg.send "Niemand heeft honger precies, er zijn nog geen broodjes besteld vandaag."

  order_all_broodjes: (send) ->
    mail = @_generate_mail()
    if mail? and mail.length > 0
      if send
        @_send_mail mail
      else
        @msg.send "De mail voor A la minute is:"
        @msg.send mail
        @msg.send "Als je de mail wil versturen bevestig dan met dit command 'bestel alle broodjes!!'"
    else
      @msg.send "Er moeten vandaag geen broodjes besteld worden!"

  _fix_name: (name) ->
    if !name? ||  name == "" || /^(?:mij|)$/i.test(name)
      name = @msg.message.user.name 
    return name

  _generate_mail: ->
    brain = new SandwichBrain @robot, @msg
    broodjes = brain.broodjes_for_today()

    formatted_broodjes = []
    for userid, broodje of broodjes
      if broodje?
          formatted_broodjes.push
            "broodje": broodje,
            "name": userid

    if formatted_broodjes.length > 0
      text = "Bestelling voor 10to1\n\n---\n\nLeveradres: Prins Boudewijnlaan 5, 2550 Kontich\n"
      for broodje in formatted_broodjes
        text += "\n------------------------------------------------------------------------------------------\n"
        name = broodje["name"]
        for line in @_lines(broodje["broodje"], 60)
          text += sprintf("%-25.25s - %-60.60s", name, line)
          name = "" 
      text += "\n-------------------------------------------------------------------------------------------\n"
      return text

    return null

  _lines: (text, length) ->
    result = []
    if text?
      p = 0
      loop
        result.push text.substr(p, 60)
        p += 60
        break unless (p < text.length)
    return result

  _send_mail: (text) ->
      nodemailer= require("nodemailer");
      nodemailer.SMTP =
        host: 'smtp.gmail.com',
        port: 465,
        ssl: true,
        use_authentication: true,
        user: env.GMAIL_SCANNER_USER,
        pass: env.GMAIL_SCANNER_PASSWORD

      @msg.send "A la minute emailen..."
      msg = @msg
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
  
  

