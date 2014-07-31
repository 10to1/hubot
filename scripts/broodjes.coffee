# Description:
#   10to1's Broodjes Management System
#
# Dependencies:
#   "cron"
#
# Configuration:
#   BROODJES_ROOMS - comma-separated list of rooms
#   BROODJES_EMAIL - email address where to send to
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

URL = "http://tto-foodz.herokuapp.com/hubot"
# URL = "http://foodz.dev/hubot"

cronJob         = require('cron').CronJob

catchRequest = (message, path, action, options, callback) ->
  console.log "Making the call"
  message.http("#{URL}#{path}").query(options)[action]() (err, res, body) ->
    callback(err,res,body)

postRequest = (msg, path, params, callback) ->
  stringParams = JSON.stringify params
  msg.http("#{URL}#{path}")
    .headers("Content-type": "application/json",'Accept': 'application/json')
    .post(stringParams) (err, res, body) ->
      callback(err, res, body)

module.exports = (robot) ->

  rooms = ["271712"]
  if process.env.BROODJES_ROOMS
    rooms = process.env.BROODJES_ROOMS.split(',')

  broadcast = new Broadcaster robot, rooms[0]

  reminderJob = new cronJob '0 50 9 * * 1-5',
                ->
                  brain = new SandwichBrain robot, null
                  sandwichlessUsers = brain.sandwichlessUsers()
                  if sandwichlessUsers && sandwichlessUsers.length
                    broadcast.send "#{sandwichlessUsers.join(', ')} Binnen 10 min verstuur ik de fax voor de broodjes!"
                  else
                    broadcast.send "Iedereen heeft zijn broodje al besteld, zeg. Goed gewerkt. Binnen 10 min verstuur ik de fax voor de broodjes."
                null
                true
                'Europe/Brussels'
  reminderJob2 = new cronJob '0 55 9 * * 1-5',
                ->
                  brain = new SandwichBrain robot, null
                  sandwichlessUsers = brain.sandwichlessUsers()
                  if sandwichlessUsers && sandwichlessUsers.length
                    broadcast.send "#{sandwichlessUsers.join(', ')} Binnen 5 min verstuur ik de fax voor de broodjes! Ge moet rap zijn!"
                null
                true
                'Europe/Brussels'

  reminderJob3 = new cronJob '0 40 9 * * 1-5',
                ->
                  brain = new SandwichBrain robot, null
                  sandwichlessUsers = brain.sandwichlessUsers()
                  if sandwichlessUsers && sandwichlessUsers.length
                    broadcast.send "#{sandwichlessUsers.join(', ')} Binnen 20 min verstuur ik de fax voor de broodjes!"
                null
                true
                'Europe/Brussels'

  reminderJob4 = new cronJob '0 58 9 * * 1-5',
                ->
                  brain = new SandwichBrain robot, null
                  sandwichlessUsers = brain.sandwichlessUsers()
                  if sandwichlessUsers && sandwichlessUsers.length
                    broadcast.send "#{sandwichlessUsers.join(', ')} Binnen 2 min verstuur ik de fax voor de broodjes! Typ rap nog iets!"
                null
                true
                'Europe/Brussels'

  reminderJob5 = new cronJob '0 59 9 * * 1-5',
                ->
                  brain = new SandwichBrain robot, null
                  sandwichlessUsers = brain.sandwichlessUsers()
                  if sandwichlessUsers && sandwichlessUsers.length
                    broadcast.send "#{sandwichlessUsers.join(', ')} Binnen 1 min verstuur ik de fax voor de broodjes! RAPPER TYPEN!!"
                null
                true
                'Europe/Brussels'

  reminderJob6 = new cronJob '15 59 9 * * 1-5',
                ->
                  brain = new SandwichBrain robot, null
                  sandwichlessUsers = brain.sandwichlessUsers()
                  if sandwichlessUsers && sandwichlessUsers.length
                    broadcast.send "#{sandwichlessUsers.join(', ')} Ik *denk* dat ge te laat gaat zijn."
                null
                true
                'Europe/Brussels'



  bestelJob = new cronJob '0 0 10 * * 1-5',
                ->
                  broadcast.send "Good news everyone! Ik ga de broodjes bestellen!"
                  handler = new Sandwicher robot, broadcast
                  handler.order_all_broodjes true
                null
                true
                'Europe/Brussels'

  robot.respond /iedereen besteld/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.show_not_ordered()

  robot.respond /(geen broodje meer voor|nooit meer iets voor)\s+(.+)/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.forget msg.match[2]

  robot.respond /welke\s+broodjes(?:\s+zijn\s+er)?\??/i, (msg) ->
    catchRequest msg, "/food", "get", {}, (err, res, body) ->
      if res.statusCode is 200
        for food in JSON.parse(body)
          msg.send "#{food.name}"
      else
        msg.reply "Kan geen broodjes vinden :("

  robot.respond /(vandaag\s+)?geen\s+broodjes/i, (msg) ->
    postRequest msg, "/orders", {all_users: "X", delete: "X"}, (err, res, body) ->
      if res.statusCode is 200
        console.log "OK: #{body}"
        handler = new Sandwicher robot, msg
        handler.remove_all_broodjes_for_today()
      else
        console.log "Error: #{err}"

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
    catchRequest msg, "/orders", "get", {}, (err, res, body) ->
      if res.statusCode is 200
        for order in JSON.parse(body)
          msg.send "#{order.username}: #{order.metadata}"
      else
        msg.send "Te ingewikkelde bestelling (status: #{res.statusCode})"

  robot.respond /bestel(?:\s+alle)?\s+broodjes(!!!?)?$/i, (msg) ->
    handler = new Sandwicher robot, msg
    handler.order_all_broodjes msg.match[1]?

#############################################

sprintf = require('sprintf').sprintf
env     = process.env

class SandwichBrain
  constructor: (robot, msg) ->
    @robot = robot
    @data = @robot.brain.data
    @msg = msg
    @setup()

  setup: ->
    date = new Date()
    @today = [date.getFullYear(), (date.getMonth() + 1), date.getDate()].join("/")
    @ensure_data()
    @pour_a_50_for_the_homies()

  ensure_data: ->
    @data ?= {users: {}, _private: {}}
    @data.broodjes ?= {}
    @data.forgotten ?= {}
    @data.broodjes[@today] ?= {}

  pour_a_50_for_the_homies: ->
    @data.forgotten["Nick Looijmans"] = "FFING CANADIAN"
    @data.forgotten["Tim Van Damme"] = "TIMMIE!"
    @data.forgotten["Tom Adriaenssen"] = "DOTZERS"
    @data.forgotten["Evert Van den Bruel"] = "BEVERT"
    @data.forgotten["Jelle Vandebeeck"] = "jelle"

  all_broodjes_for_user: (user) ->
    result = [] unless user
    for day, order of @data.broodjes
      if order[user]
          result.push order[user]
      else
        for u, broodje of order
          result.push broodje if broodje?
    result

  forget: (user) ->
    @data.forgotten[user] = @today if user

  unforget: (user) ->
    delete @data.forgotten[user]

  forgotten_users: ->
    return [] unless @data.forgotten
    Object.keys(@data.forgotten)

  is_forgotten: (user) ->
    @data.forgotten[user]

  order_broodje_for_today: (user, broodje) ->
    @unforget user
    postRequest @msg, "/orders", {username: user, metadata: broodje}, (err, res, body) ->
      if res.statusCode is 200
        console.log "OK: #{body}"
      else
        console.log "Error: #{err}"
    @data.broodjes[@today][user] = broodje

  broodjes_for_today: ->
    @data.broodjes[@today]

  # TODO: Makes this set null to all users so the cron doesn't complain anymore
  no_broodjes_for_today: ->
    @data.broodjes[@today] = {}
    for own key, user of @data.users
      name = user.name
      unless ((name is "HUBOT") || (@is_forgotten(name)))
        @data.broodjes[@today][user] = null

  no_broodje_for_today: (user) ->
    old_bun = @data.broodjes[@today][user]
    @data.broodjes[@today][user] = null
    postRequest @msg, "/orders", {username: user, delete: "X"}, (err, res, body) ->
      if res.statusCode is 200
        console.log "OK: #{body}"
      else
        console.log "Error: #{err}"
    old_bun

  sandwichlessUsers: ->
    result = []
    orderedUsers = Object.keys @broodjes_for_today()
    for own key, user of @data.users
      name = user.name
      unless (orderedUsers.some (word) -> word is name)
        result.push name unless ((name is "HUBOT") || (@is_forgotten(name)))
    return result

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
    sandwichlessUsers = brain.sandwichlessUsers()
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

    @msg.send "Geen broodjes vandaag. Op naar de Quick!"

    # contains_broodjes = no
    # for name, broodje of broodjes
    #     if broodje != null
    #       contains_broodjes = yes
    #       @msg.send "Hey #{name}, uw broodje is geannuleerd! #fdj"

    brain.no_broodjes_for_today()

  remove_broodje_for_today: (name) ->
    brain = new SandwichBrain @robot, @msg
    name = @_fix_name name
    ok = brain.no_broodje_for_today(name)
    if ok?
      @msg.send "#{name} had jij besteld? Ik ben het al vergeten."
    else
      @msg.send "#{name} as you wish."

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
    return unless process.env.BROODJES_ENABLED
    broodjes = brain.broodjes_for_today()
    unless broodjes.length
      @msg.send "Geen broodjes vandaag, dan doe ik ook de moeite niet"
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

    text = "Bestelling voor 10to1\n\n---\n\nLeveradres: Prins Boudewijnlaan 5, 2550 Kontich\n\n"
    text += "------------------------------------------------------------------------------------------\n"
    if formatted_broodjes.length > 0
      for broodje in formatted_broodjes
        name = broodje["name"]
        sep = "-"
        for line in @_lines(broodje["broodje"], 60)
          if line.length > 0
            text += sprintf("%-25.25s %s %-60.60s\n", name, sep, line)
            sep = " "
            name = ""
    else
      text += "Vandaag hebben wij geen broodjes nodig."

    text += "-------------------------------------------------------------------------------------------\n"
    return text

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
      @msg.send "A la minute emailen..."
      @msg.send "In theorie zijn de broodjes verstuurd, geen stress..."

# To use when you don't have a @msg object available
class Broadcaster
  constructor: (robot, rooms) ->
    @robot = robot
    @rooms = rooms

  send: (text) ->
    @robot.messageRoom @rooms, text
