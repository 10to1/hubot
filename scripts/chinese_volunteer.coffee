# Description:
#   vind een vrijwilliger voor elk rotkarwei
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
#
# Author:
#   mathias
frases = [
        'doet dat met plezier'
        'zal dat wel doen'
        'helpt je daar zo meer verder'
        'is daar de beste in'
        'heeft daar lang voor gestudeerd'
        'heeft daar ooit nog mee in de krant gestaan'
        'zal daar iemand voor aanduiden'
        'mag dat niet van zijn vakbond'
        'kunnen we daar eigenlijk niet mee vertrouwen'
        'heeft dat de vorige keer om zeep geholpen'
]

module.exports = (robot) ->
  robot.hear /vrijwilliger|(wie (wil|kan).*\?)|(wil|kan)( er)? iemand.*\?/i, (msg) ->
    team = []
    for own key, user of robot.brain.users()
      team.push "#{user.name}" if "#{user.name}" != robot.name

    volunteer = msg.random team
    frase = msg.random frases
    if volunteer
      msg.send "#{volunteer} #{frase}"
    else
      msg.send "De lieve heer #{frase}"