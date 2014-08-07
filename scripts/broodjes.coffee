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

cronJob    = require('cron').CronJob
HttpClient = require 'scoped-http-client'
Joe        = require('../joe')
joe        = new Joe("http://tto-foodz.herokuapp.com", HttpClient)

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

name_or_me = (testname, msg) ->
  if !testname? ||  testname == "" || /^(?:mij|)$/i.test(testname)
    name = msg.message.user.name
  else
    name = testname
  return name

module.exports = (robot) ->

  rooms = ["271712"]
  if process.env.BROODJES_ROOMS
    rooms = process.env.BROODJES_ROOMS.split(',')

  broadcast = new Broadcaster robot, rooms[0]

  poke = (msg, reply) ->
    joe.users_without_orders (error, users) ->
      if error
        msg.send "Ik ben bang dat er iets mis zal gaan bij het bestellen van de broodjes. Wie kijkt dat eens na? (#{error})"
      else
        if users.length
          msg.send "#{users.join(', ')} #{reply}"
        else
          msg.send "Iedereen heeft zijn broodje al besteld, zeg. Goed gewerkt."

  cron_jobs = {
    '0 40 9 * * 1-5' : "Binnen 20 min bestel ik de broodjes!",
    '0 50 9 * * 1-5' : "Binnen 10 min bestel ik de broodjes!",
    '0 55 9 * * 1-5' : "Binnen 5 min bestel ik de broodjes!",
    '0 59 9 * * 1-5' : "Binnen 1 minuut bestel ik de broodjes!",
    '15 59 9 * * 1-5' : "Ik denk dat je te laat gaat zijn!"
  }
  for time, message of cron_jobs
    poker = ->
      poke broadcast, message
    new cronJob time, poker, null, true, 'Europe/Brussels'

  robot.respond /iedereen besteld/i, (msg) ->
    poke msg, "moeten nog bestellen"

  robot.respond /(geen broodje meer voor|nooit meer iets voor)\s+(.+)/i, (msg) ->
    name = msg.match[2]
    msg.send "Binnen 3 dagen ben ik #{name} wel vergeten."

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
        msg.send "Geen broodjes vandaag. Op naar de Quick!"
      else
        msg.send "Ik ga toch bestellen, jullie moeten iets gezonder eten!"

  robot.respond /voor\s+(.+?)\s+geen\s+broodje|geen\s+broodje\s+voor\s+(.+?)?/i, (msg) ->
    user = name_or_me(msg.match[1] ? msg.match[2], msg)
    postRequest msg, "/orders", {username: user, delete: "X"}, (err, res, body) ->
      if res.statusCode is 200
        msg.send "#{user} had jij besteld? Ik ben het al vergeten."
      else
        msg.send "#{user}, ik vind dat je wel iets moet eten!"

  # test: http://www.rubular.com/r/yAApRvQH5D
  robot.respond /(doe|voor|bestel|bespreek|bezorg|ontbiedt|reserveer|eis|onderspreek)(?:(?:\s+voor)?\s+((?!(?:ne|een|iets)).*?))?(\s+maa?r?)?\s+(een|ne|iets)\s+(.*)/i, (msg) ->
    broodje = msg.match[5]
    user = name_or_me(msg.match[2], msg)
    postRequest msg, "/orders", {username: user, metadata: broodje}, (err, res, body) ->
      if res.statusCode is 200
        if name == @msg.message.user.name
          msg.send "#{@msg.message.user.name} gaat straks een #{broodje} eten"
        else
          msg.send "#{@msg.message.user.name} zorgt ervoor dat #{user} straks een #{broodje} kan eten"
      else
        msg.send "#{user}, ik denk niet dat een #{broodje} zo'n goed idee is."

  robot.respond /broodjes/i, (msg) ->
    catchRequest msg, "/orders", "get", {}, (err, res, body) ->
      if res.statusCode is 200
        for order in JSON.parse(body)
          msg.send "#{order.username}: #{order.metadata}"
      else
        msg.send "Te ingewikkelde bestelling (status: #{res.statusCode})"

  robot.respond /bestel(?:\s+alle)?\s+broodjes(!!!?)?$/i, (msg) ->
    msg.send "Geen stress, dat komt in orde, rond 10u."


# To use when you don't have a @msg object available
class Broadcaster
  constructor: (robot, rooms) ->
    @robot = robot
    @rooms = rooms

  send: (text) ->
    @robot.messageRoom @rooms, text
