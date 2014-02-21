googleNameForName = (name) ->
  hash = {
    "gmail": "Google Play Mail",
    "android": "Google Play OS",
    "chromecast": "Google Play Chromecast",
    "chrome": "Google Play Chrome",
    "google music": "Google Play Music",
    "google maps": "Google Play Maps",
    "hangouts": "Google Play Hangouts",
    "gtalk": "Google Play Talk"
  }
  hash[name]

module.exports = (robot) ->
  robot.hear /hangouts|gtalk|gmail|google maps?|android|chromecast|chrome|google music|gmusic/ig, (msg) ->
    return if robot.name == msg.message.user.name
    keyword = msg.match[0]
    keyword = "google music" if keyword == "gmusic"
    keyword = "google maps" if keyword == "google map"
    extra = msg.random ["Beta", "All Access", "", "Unlimited", "2000"]
    name = googleNameForName(keyword)
    if extra
      msg.send "*#{name} #{extra}*"
    else
      msg.send "*#{name}*"