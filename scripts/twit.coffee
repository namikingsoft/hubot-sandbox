Twit = require "twit"

MENTION_ROOM = process.env.TWIT_MENTION_ROOM || "#general"
MAX_FETCH_COUNT = 5
CONFIG =
  consumer_key: process.env.TWIT_CONSUMER_KEY
  consumer_secret: process.env.TWIT_CONSUMER_SECRET
  access_token: process.env.TWIT_ACCESS_TOKEN_KEY
  access_token_secret: process.env.TWIT_ACCESS_TOKEN_SECRET

module.exports = (robot) ->

  message_queue = []

  send = ->
    if message_queue.length > 0
      message = message_queue.shift()
      robot.messageRoom MENTION_ROOM, message

  search_and_queue = ->
    twit = new Twit CONFIG
    search_list = robot.brain.data.search_list
    for search, i in search_list
      do (search, i) ->
        param =
          q: search.text
          count: MAX_FETCH_COUNT
          since_id: search.since_id
        twit.get 'search/tweets', param, (err, data) ->
          if err
            console.log "Error getting tweets: #{err}"
            return
          return unless data.statuses?
          return unless data.statuses.length > 0
          search.since_id = data.statuses[0].id_str
          robot.brain.data.search_list[i] = search
          for tweet in data.statuses.reverse()
            user = tweet.user
            text = "#{tweet.text} - #{user.name}@#{user.screen_name}"
            url = "http://twitter.com/#{user.screen_name}/status/#{tweet.id_str}"
            message = "#{text}\n#{url}"
            message_queue.push message

  robot.brain.on 'loaded', ->
    robot.brain.data.search_list ||= []
    setInterval search_and_queue, 1000 * 30
    setInterval send, 1000 * 10

  robot.respond /twit fetch/i, -> search_and_send()

  robot.respond /twit reset/i, (res) ->
    robot.brain.data.search_list = []
    res.reply "OK. Search list was cleared"

  robot.respond /twit add ([a-zA-Z0-9_]+) (.*)/i, (res) ->
    name = res.match[1]
    text = res.match[2]
    robot.brain.data.search_list.push
      name: name
      text: text
      since_id: 1
    res.reply "Added: #{name} -> #{text}"

  robot.respond /twit rm ([a-zA-Z0-9_]+)/i, (res) ->
    name = res.match[1]
    robot.brain.data.search_list = robot.brain.data.search_list.filter (search) ->
      search.name != name
    res.reply "Removed: #{name}"

  robot.respond /twit list/i, (res) ->
    res.reply "\n" + JSON.stringify(robot.brain.data.search_list, null, '  ')


