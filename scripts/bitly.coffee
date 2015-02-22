# Metadata lookup for bit.ly links
#
# <bit.ly link> - returns info about the link (title, created_by)
#
#
# <Your bit.ly username>
if(!process.env.HUBOT_BITLY_LOGIN)
  console.warn("Warning: bit.ly login not set")

# <Your bit.ly api key -> http://bitly.com/a/your_api_key >
if(!process.env.HUBOT_BITLY_API_KEY)
  console.warn("Warning: bit.ly api key not set")

module.exports = (robot) ->
  robot.hear bitly.link, (msg) ->
    msg.http(bitly.uri msg.match[0]).get() (err, res, body) ->
      if res.statusCode is 200
        data = JSON.parse(body)
        msg.send bitly.url(data)

bitly =
  link: /// (
    ?: http(s)?://bit.ly/
    ) \S+ ///

  uri: (link) -> "https://api-ssl.bitly.com/v3/expand?shortUrl=#{link}&login=#{this.login()}&apiKey=#{this.api_key()}"

  url: (data) ->
    console.log data.data
    if data.data
      url = "#{data.data.expand[0].long_url}"
      "Also known as #{url}"
    else
      "Nothing found on the bit.ly"

  login: ->
    process.env.HUBOT_BITLY_LOGIN

  api_key: ->
    process.env.HUBOT_BITLY_API_KEY