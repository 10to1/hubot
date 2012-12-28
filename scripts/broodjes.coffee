# Description:
#   10to1's Broodjes Management System
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot broodjes - Toont een lijst van bestelde broodjes
#   hubot welke broodjes - Toon een lijst van alle mogelijke broodjes
#   hubot voor mij geen broodje - Verwijdert je bestelling voor vandaag
#   hubot geen broodjes - Verdwijdert alle broodjes voor vandaag
#   hubot bestel een <broodje> - Bestel ene broodje voor vandaag
#   hubot bestel alle broodjes - Stuurt een fax naar A La Minute
#   hubot iedereen besteld - Check om te zien of iedereen besteld heeft
#   hubot geen broodje meer voor (iemand) - No longer show person in "iedereen besteld" list
#
# Author:
#   inferis

module.exports = (robot) ->

  robot.respond /iedereen besteld/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.show_not_ordered()

  robot.respond /(geen broodje meer voor|nooit meer iets voor)\s+(.+)/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.forget msg.match[2]

  robot.respond /welke\s+broodjes(?:\s+zijn\s+er)?\??/i, (msg) ->
    msg.http("http://hummercatch.herokuapp.com/hubot/food").get() (err, res, body) ->
      if res.statusCode is 200
        msg.send data
      else
        msg.reply "Kan geen broodjes vinden :("

  robot.respond /(vandaag\s+)?geen\s+broodjes/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.remove_all_broodjes_for_today()

  robot.respond /voor\s+(.+?)\s+geen\s+broodje|geen\s+broodje\s+voor\s+(.+?)?/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.remove_broodje_for_today msg.match[1] ? msg.match[2]

  # test: http://www.rubular.com/r/yAApRvQH5D
  robot.respond /(doe|voor|bestel|bespreek|bezorg|ontbiedt|reserveer|eis|onderspreek)(?:(?:\s+voor)?\s+((?!(?:ne|een|iets)).*?))?(\s+maa?r?)?\s+(een|ne|iets)\s+(.*)/i, (msg) ->
    handler = new Sandwicher robot, msg
    if (msg.match[4] == "iets")
      broodje = handler.find_special_broodje msg.match[5]
    else
      broodje = msg.match[5]
    handler.order_broodje_for_today msg.match[2], broodje

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

  all_broodjes_for_user: (user) ->
    return [] unless @robot.brain.data.broodjes

    result = []
    for day, order of @robot.brain.data.broodjes
      if user?
        if order[user]
          result.push order[user]
      else
        for u, broodje of order
          result.push broodje if broodje?
    return result

  forget: (user) ->
    if user
      @robot.brain.data.forgotten = {} unless @robot.brain.data.forgotten
      @robot.brain.data.forgotten[user] = @today()

  unforget: (user) ->
    @robot.brain.data.forgotten = {} unless @robot.brain.data.forgotten
    delete @robot.brain.data.forgotten[user]

  forgotten_users: ->
    return [] unless @robot.brain.data.forgotten
    Object.keys(@robot.brain.data.forgotten)

  is_forgotten: (user) ->
    @robot.brain.data.broodjes = {} unless @robot.brain.data.broodjes
    @robot.brain.data.forgotten[user]

  order_broodje_for_today: (user, broodje) ->
    @unforget user
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

  forget: (person) ->
    brain = new SandwichBrain @robot, @msg
    brain.forget person
    @msg.send "Goed, we doen alsof #{person} er niet is."

  show_list_of_broodjes: ->
    @msg.send "Geen idee! Hier is de link: http://www.alaminute.be/prijslijst.html"

  show_not_ordered: ->
    brain = new SandwichBrain @robot, @msg
    sandwichlessUsers = []
    orderedUsers = for name, broodje of brain.broodjes_for_today()
      name
    for own key, user of @robot.brain.data.users
      name = "#{user['name']}"
      unless (orderedUsers.some (word) -> word is name)
        sandwichlessUsers.push name unless (name is "HUBOT" || brain.is_forgotten(name))
    if sandwichlessUsers && sandwichlessUsers.length
      @msg.send "Nog niet besteld: #{sandwichlessUsers.join(', ')}"
    else
      @msg.send "Iedereen heeft besteld."

  find_special_broodje: (type) ->
    brain = new SandwichBrain @robot, @msg
    if type == "lekkers" || type == "lekkers"
      broodjes = brain.all_broodjes_for_user(@msg.message.user.name)
    else if type == "zot" || type == "verrassend"
      broodjes = brain.all_broodjes_for_user(null)
    else
      broodjes = []

    broodjes = [ "grote smos mexicano met samourai", "slaatje spek en appeltjes", "fitness smos hesp/kaas", "curryrol", "broodje choco" ] if broodjes.length == 0 #default choices
    return broodjes[Math.floor(Math.random()*broodjes.length)]

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
      text = "Bestelling voor 10to1\n\n---\n\nLeveradres: Prins Boudewijnlaan 5, 2550 Kontich\n\n"
      for broodje in formatted_broodjes
        text += "------------------------------------------------------------------------------------------\n"
        name = broodje["name"]
        sep = "-"
        for line in @_lines(broodje["broodje"], 60)
          if line.length > 0
            text += sprintf("%-25.25s %s %-60.60s\n", name, sep, line)
            sep = " "
            name = ""
      text += "-------------------------------------------------------------------------------------------\n"
      return text

    return null

  _lines: (text, length) ->
    result = []
    if text?
      p = 0
      loop
        x = text.substr(p, 60).replace /^\s+|\s+$/g, ""
        result.push x unless x.length == 0
        p += 60
        break unless p < text.length
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
