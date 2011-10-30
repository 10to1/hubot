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

  email: ->
    @get_freckle().email

  get_freckle: ->
    @robot.brain.data.freckle = {} unless @robot.brain.data.freckle
    freckle = @robot.brain.data.freckle[@msg.message.user.name]
    if freckle.constructor.toString().indexOf('Object') < 0
      freckle = @robot.brain.data.freckle[@msg.message.user.name] = {}
    freckle



class FreckleRequest

  constructor: (type, robot, msg) ->
    @robot = robot
    @msg = msg
    @handler = new FreckleHandler @robot, @msg

    domain = process.env.HUBOT_FRECKLE_TOKEN
    domain = "10to1"

    if domain?
      @url = "http://#{domain}.letsfreckle.com/api/#{type}.json"
    else
      msg.send "There's no freckle domain set up. Specify HUBOT_FRECKLE_DOMAIN first."
      @url = null


    unless @handler.token?
      msg.send "There's no freckle token set up. Add your token first."

#    robot.brain.data.freckle = {} unless robot.brain.data.freckle
#    freckle = robot.brain.data.freckle[msg.message.user.name]
#    unless freckle
#      msg.send "You need to give me your freckle token first. Use 'set my freckle token to <token>'"
#      return

  create: ->
    @msg
      .http(@url)
      .headers('X-FreckleToken': @handler.token())

  get_projects: ->
    req = @create()
    msg = @msg
    (callback) ->
      req
        .get() (err, res, body) ->
          if body?
            projects = eval body
            callback projects
          else
            callback null


module.exports = (robot) ->

  robot.respond /freckle\s+email=(.+)\s+token=(.+)/i, (msg) ->
    handler = new FreckleHandler robot, msg
    handler.set_email "#{msg.match[1]}"
    handler.set_token "#{msg.match[2]}"
    msg.send "Okay, I'll remember your Freckle setup."


  robot.respond /freckle\s+forget/i, (msg) ->
    handler = new FreckleHandler robot, msg
    handler.forget null
    msg.send 'Okay, I forgot your Freckle setup.'

  robot.respond /freckle\s+setup\??/i, (msg) ->
    handler = new FreckleHandler robot, msg
    if handler.email()? and handler.token()?
      msg.send "Your Freckle email is #{handler.email()} and your token is #{handler.token()}"
    else if handler.email()
      msg.send "Your Freckle email is #{handler.token()}, but I don't know about your token."
    else if handler.token()
      msg.send "I don't know about your Freckle email, but your token is #{handler.token()}"
    else
      msg.send 'I don\'t know your Freckle email, nor about your token.'


  robot.respond /freckle(\s+sorted)?\s+projects\??/i, (msg) ->
    request = new FreckleRequest "projects", robot, msg
    request.get_projects() (projects) ->
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
      list = ""
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
    request = new FreckleRequest "entries", robot, msg
    time = msg.match[1]
    proj = msg.match[2]
    desc = msg.match[3]

    request.get_projects() (projects) ->
      for project in projects
        if project.project.name == proj
          request.create()
            .post({ minutes: time, user: request.handler().email(), 'project-id':project.project.id, description:desc }) (err, res, body) ->
              msg.send err
              msg.send res
              msg.send body
          return
      msg.send 'no project found.'
