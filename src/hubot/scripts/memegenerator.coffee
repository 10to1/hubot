# Allows Hubot generate memes
#
# generate meme <type> with <line1>, <line2> - generates a meme with the specified type. You can add up to two lines of text, seperated by a comma.
# what memes - gives you a list of all supported meme types.
memes =
   successkid: { generator: 121, image: 1031 }
   sparta: { generator: 9688, image: 1013 }
   arnold: { generator: 544, image: 1236 }
   advicedog: { generator: 225, image: 32 }
   yuno: { generator: 2, image: 166088 }
   scumbag: { generator: 142, image: 366130 }
   butthurt: { generator: 31, image: 1438 }
   yodawg: { generator: 79, image: 108785 }


module.exports = (robot) ->
  robot.respond /what memes.*/i, (msg) ->
    msg.send "You can use the following memes, #{msg.message.user.name}:"

    result = ""
    result += " * #{name}\n" for name, info of memes
    msg.send result

  robot.respond /gen(?:erate)? meme (\S+) with ([^,]*)(?:,\s*(.*))?/i, (msg) ->
    meme = memes[msg.match[1]]

    if meme
      msg
        .http('http://memegenerator.net/Instance/Create')
        .query
          generatorID: meme.generator
          imageID: meme.image
          text0: msg.match[2]
          text1: msg.match[3]
        .post() (err, res, body) ->
          if err
            msg.send "Woops, that didn't work. Sorry.'"
          else
            location = "http://memegenerator.net#{res.headers.location}"
            msg
              .http(location)
              .get() (err2, res2, body2) ->
                if err
                  msg.send "Woops, that didn't work. Sorry.'"
                else
                  matches = body2.match /<img src="(\/cache\/instances\/[^"]*)"/
                  if matches[1]
                    msg.send "http://memegenerator.net#{matches[1]}"
                  else
                    msg.send "Alas, I failed."
    else
      msg.send "I don't know about a meme called '#{msg.match[1]}'."
      msg.send "Try asking me what memes there are."

