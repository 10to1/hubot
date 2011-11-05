# Freckle integration for hubot
#
# set my freckle token to <token> - todo
# forget my freckle token - todo
# what is my freckle token - todo

class FreckleHandler

  constructor: (robot, msg) ->
    @robot = robot
    @msg = msg

  set_token: (token) ->
    @get_freckle().token = token

  token: ->
    @get_freckle().token

  set_email: (email) ->
    @get_freckle().email = email
    if email?
      request = new FreckleRequest "users", robot, msg

      request
        .create()
        .get() (err, res, body) ->
          users = eval body
          @msg.send users
          for user in users
            @msg.send user
    else
      @get_freckle().userid = nil

  email: ->
    @get_freckle().email

  get_freckle: ->
    @robot.brain.data.freckle = {} unless @robot.brain.data.freckle
    @robot.brain.data.freckle[@msg.message.user.name]


class FreckleRequest

  constructor: (type, robot, msg) ->
    @robot = robot
    @msg = msg

    domain = process.env.HUBOT_FRECKLE_DOMAIN
    if domain
      msg.send "There's no freckle domain set up. Specify HUBOT_FRECKLE_DOMAIN first."
      @url = null
    else
      @url = "http://#{domain}.letsfreckle.com/api/#{type}.json"

    robot.brain.data.freckle = {} unless robot.brain.data.freckle
    freckle = robot.brain.data.freckle[msg.message.user.name]
    unless freckle
      msg.send "You need to give me your freckle token first. Use 'set my freckle token to <token>'"
      return

  create:(callback) ->
    handler = new FreckleHandler @robot, @msg
    @msg
      .http(@url)
      .headers('X-FreckleToken': handler.token())


module.exports = (robot) ->

  robot.respond /(?:freckle\s+token|set\s+my\s+freckle\s+token\s+to)\s+(.*)/i, (msg) ->
    handler = new FreckleHandler robot, msg
    if msg.match[1] == "clear"
      handler.set_token null
      msg.send 'Okay, I forgot your freckle token.'
    else
      handler.set_token "#{msg.match[1]}"
      msg.send "Okay, I'll remember your freckle token."


  robot.respond /(?:freckle\s+token\s+clear$|forget\s+my\s+freckle\s+token)/i, (msg) ->
    handler = new FreckleHandler robot, msg
    handler.set_token null
    msg.send 'Okay, I forgot your freckle token.'


  robot.respond /(?:freckle\stoken$|what\s+is\s+my\s+freckle\s+token)\??/i, (msg) ->
    handler = new FreckleHandler robot, msg
    if handler.token()
      msg.send "Your freckle token is #{handler.token()}"
    else
      msg.send 'I don\'t know your freckle token.'


  robot.respond /(?:freckle\s+email|set\s+my\s+freckle\s+email\s+to)\s+(.*)/i, (msg) ->
    handler = new FreckleHandler robot, msg
    if msg.match[1] == "clear"
      handler.set_email null
      msg.send 'Okay, I forgot your freckle email.'
    else
      handler.set_email "#{msg.match[1]}"
      msg.send "Okay, I'll remember your freckle email."


  robot.respond /(?:freckle\s+email\s+clear$|forget\s+my\s+freckle\s+email)/i, (msg) ->
    handler = new FreckleHandler robot, msg
    handler.set_email null
    msg.send 'Okay, I forgot your freckle email.'


  robot.respond /(?:freckle\s+email|what\s+is\s+my\s+freckle\s+email)\??/i, (msg) ->
    handler = new FreckleHandler robot, msg
    if handler.email()
      msg.send "Your freckle email is #{handler.email()}"
    else
      msg.send 'I don\'t know your freckle email.'


  robot.respond /freckle\s+info/i, (msg) ->
    handler = new FreckleHandler robot, msg
    if handler.email()
      msg.send "Your freckle email is #{handler.email()}"
    else
      msg.send 'I don\'t know your freckle email.'
    if handler.token()
      msg.send "Your freckle token is #{handler.token()}"
    else
      msg.send 'I don\'t know your freckle token.'


  robot.respond /freckle(\s+sorted)?\s+projects\??/i, (msg) ->
    request = new FreckleRequest "projects", robot, msg

    request
      .create()
      .get() (err, res, body) ->
        msg.send body
        list = ""
        projects = eval body
        if msg.match[1]
          # is "sorted" is passed, sort by minutes descending. Otherwise, sort alphabetically.
          projects.sort (a,b) ->
            return -1 if a.project.minutes > b.project.minutes
            return 1 if a.project.minutes < b.project.minutes
            return 0
        else
          projects.sort (a,b) ->
            return 1 if a.project.name > b.project.name
            return -1 if a.project.name < b.project.name
            return 0

        # generate the list of projects
        for project in projects
          if project.project.enabled
            list += "- #{project.project.name}"
            list += "*" unless project.project.billable
            list += ": "
            if project.project.minutes > 0
              minutes = project.project.minutes % 60
              hours = Math.floor((project.project.minutes) / 60)
              days = Math.floor(hours / 8)
              hours = hours % 8
              list += "#{days}d" if days > 0
              list += "#{hours}h" if hours > 0 or (days > 0 and minutes > 0)
              list += "#{minutes}m" if minutes > 0
            else
              list += "Nothing booked yet."
            list += "\n"
        if list
          msg.send list
        else
          msg.send "There aren't any!"


  robot.respond /freckle\s+add\s+(.+)\s+to\s+(.+)\s+(?:for|on|as|doing)\s+(.+)/i, (msg) ->
    request = new FreckleRequest "projects", robot, msg

    request
      .create()
      .http("http://#{domain}.letsfreckle.com/api/projects.json")
      .query
        hl: 'en'
        q: msg.match[3]
      .headers
        'Accept-Language': 'en-us,en;q=0.5',
        'Accept-Charset': 'utf-8',
        'User-Agent': "Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"
      .get() (err, res, body) ->
        # Response includes non-string keys, so we can't use JSON.parse here.
        json = eval("(#{body})")
        msg.send json.rhs || 'Could not compute.'
