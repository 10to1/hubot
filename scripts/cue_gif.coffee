# Description:
#   Will display a gif on cue.
#   For example:
#         cue inferis
#         => http://f.cl.ly/items/3q2Z1C430G2l1o13131b/animated-2012-09-13_16h-20m-29s.gif
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#
#   cue <person_name>
#
# Author:
#   pjaspers

module.exports = (robot) ->

  robot.hear /cue @?(lewis|bowling|bowlboy|delul)/, (msg) ->
    sendEpicGifForName("lewis", msg)

  robot.hear /cue @?(piet|junkiesxl)/, (msg) ->
    sendEpicGifForName("pjaspers", msg)

  robot.hear /cue @?(inferis|geknipt|dotter|dottom|a3|maaagd)/, (msg) ->
    sendEpicGifForName("inferis", msg)

  robot.hear /cue @?(jelle|verbeeckx|fousa|jaakske)/, (msg) ->
    sendEpicGifForName("fousa", msg)

  robot.hear /cue @?(bob|bab|bib|boob)/, (msg) ->
    sendEpicGifForName("reprazent", msg)

  robot.hear /cue @?(pcbob)/, (msg) ->
    sendEpicGifForName("pcbob", msg)

  robot.hear /cue @?(soffe|sophie|poeziemauw)/, (msg) ->
    sendEpicGifForName("poeziemauw", msg)

  robot.hear /cue @?(atog|koen)/, (msg) ->
    sendEpicGifForName("atog", msg)

  robot.hear /cue @?(evert)/, (msg) ->
    sendEpicGifForName("evert", msg)

  robot.hear /cue @?(tomk|honcho)/, (msg) ->
    sendEpicGifForName("tomk", msg)

  robot.hear /cue @?(bram|bramon|chili|sombrero)/, (msg) ->
    sendEpicGifForName("bram", msg)

  robot.hear /cue @?(koekoek)/, (msg) ->
    sendEpicGifForName("koekoek", msg)

  robot.hear /cue @?(tentoone|friends|team|jebus)/, (msg) ->
    sendEpicGifForName("koekoek", msg)

epicGifForName = (name) ->
  hash = {
    lewis: "https://pile.pjaspers.com/lewis.gif",
    pjaspers: "http://f.cl.ly/items/2w3V2T290K1d2x3c1O2c/animated-2012-09-14_14h-36m-39s.gif",
    inferis: "http://f.cl.ly/items/3q2Z1C430G2l1o13131b/animated-2012-09-13_16h-20m-29s.gif",
    fousa: "http://cl.ly/image/0L0b2v1J3F47/animated-2012-09-14_10h-19m-23s.gif",
    atog: "http://f.cl.ly/items/1W2Z1g1625210Q1H3f3m/animated-2012-08-24_15h-50m-00s.gif",
    tomk: "http://cl.ly/0g250e030Z31293f2D1l",
    poeziemauw: "http://f.cl.ly/items/1y0p2H1U1k1W090f2r1A/animated-2012-09-27_15h-59m-51s.gif",
    reprazent: "http://f.cl.ly/items/0C2d062j0B1P3F0v3h47/animated-2012-08-29_15h-01m-36s.gif",
    pcbob: "http://f.cl.ly/items/2e432e1K0J2x111J331V/PCBOB.gif",
    koekoek: "http://f.cl.ly/items/0m1l2q1F452B3D3f0835/Flint%202013-10-11%20at%2011.47.44%20am.gif",
    evert: "http://f.cl.ly/items/1j1b1N3Y381z2Z341Q32/animated-2012-09-11_14h-59m-58s.gif",
    bram: "http://f.cl.ly/items/3i2W463A011G1Q0s0s0u/bram-small.gif",
    tentoone: "https://pile.pjaspers.com/last_supper_10to1.gif"}
  hash[name]

sendEpicGifForName = (name, msg) ->
  if msg.message.user.name != "HUBOT"
    msg.send epicGifForName(name)
