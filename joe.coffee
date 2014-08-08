module.exports = class Joe
  constructor: (url, http_client) ->
    @url = url
    @client = http_client.create(url)

  orders: (callback) ->
    @get "hubot/orders", callback

  users_without_orders: (callback) ->
    @get "hubot/users/sandwichless", callback

  all_food: (callback) ->
    @get "hubot/food", callback

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
          callback null, JSON.parse(body)
        else
          callback error, null

  post: (path, params, callback) ->
    stringParams = JSON.stringify params
    @client.headers("Content-type": "application/json",'Accept': 'application/json').scope path, (cli) ->
      cli.post(stringParams) (error, response, body) ->
        if response.statusCode is 200
          callback(null, body)
        else
          callback error, response
