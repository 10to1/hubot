googleNameForName = (name) ->
  hash = {
    "gmail": "Google Play Mail",
    "android": "Google Play OS",
    "chromecast": "Google Play Chromecast",
    "chrome": "Google Play Chrome",
    "google music": "Google Play Music",
    "hangouts": "Google Play Hangouts",
    "gtalk": "Google Play Talk"
  }
  hash[name]

module.exports = (robot) ->
  robot.hear /gmail|android|chromecast|chrome|google music|gmusic/ig, (msg) ->
    return if robot.name == msg.message.user.name
    keyword = msg.match[0]
    keyword = "google music" if keyword == "gmusic"
    msg.send "*#{googleNameForName(keyword)}*"