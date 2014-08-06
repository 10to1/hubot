module.exports = class Joe
  constructor: (url, http_client) ->
    @url = url
    @client = http_client.create(url)

  orders: (callback) ->
    @get "hubot/orders", (error, body) ->
      if error
        callback "Error fetching orders: #{error}"
      else
        callback null, JSON.parse(body)

  users_without_orders: (callback) ->
    @get "hubot/users/sandwichless", (error, body) ->
      if error
        callback "Error fetching orders: #{error}"
      else
        callback null, JSON.parse(body)

  all_food: (callback) ->
    @get "hubot/food", (error, body) ->
      if error
        callback "Error fetching available food: #{error}"
      else
        callback null, JSON.parse(body)

  cancel_order: (username, callback) ->
    @post "hubot/orders", {username: username, delete: "X"}, callback

  cancel_all_orders: (callback) ->
    @post "hubot/orders", {all_users: "X", delete: "X"}, callback

  order: (username, order_line, callback) ->
    @post "hubot/orders", {username: username, metadata: order_line}, callback

  get: (path, callback) ->
    @client.scope path, (cli) ->
      cli.get() (error, response, body) ->
        if response.statusCode is 200
          callback(null, body)
        else
          callback(error, null)

  post: (path, params, callback) ->
    stringParams = JSON.stringify params
    @client.headers("Content-type": "application/json",'Accept': 'application/json').scope path, (cli) ->
      cli.post(stringParams) (error, response, body) ->
        if response.statusCode is 200
          callback(null, body)
        else
          callback error, response
