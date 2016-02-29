Twit = require "twit"

MENTION_ROOM = process.env.TWITTER_MENTION_ROOM || "#general"
MAX_FETCH_COUNT = 5
CONFIG =
  consumer_key: process.env.TWITTER_CONSUMER_KEY
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET
  access_token: process.env.TWITTER_ACCESS_TOKEN_KEY
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET

module.exports = (robot) ->

  search_and_send = ->
    twit = new Twit CONFIG
    searches = robot.brain.data.searches
    for search in searches
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
        for tweet in data.statuses.reverse()
          user = "@#{tweet.user.screen_name}"
          text = "#{user}さんが#{search.name}について、発言しています。"
          url = "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id_str}"
          message = "#{text}\n#{url}"
          robot.messageRoom MENTION_ROOM, message
    robot.brain.data.searches = searches

  robot.brain.on 'loaded', ->
    robot.brain.data.searches ||= []
    setInterval search_and_send, 1000 * 30 # every 20 sec

  robot.respond /twitter fetch/i, -> search_and_send()

  robot.respond /twitter reset/i, (res) ->
    robot.brain.data.searches = []
    res.reply "OK. Search list was cleared"

  robot.respond /twitter add ([a-zA-Z0-9_]+) (.*)/i, (res) ->
    name = res.match[1]
    text = res.match[2]
    robot.brain.data.searches.push
      name: name
      text: text
      since_id: 1
    res.reply "Added: #{name} -> #{text}"

  robot.respond /twitter rm ([a-zA-Z0-9_]+)/i, (res) ->
    name = res.match[1]
    robot.brain.data.searches = robot.brain.data.searches.filter (search) ->
      search.name != name
    res.reply "Removed: #{name}"

  robot.respond /twitter list/i, (res) ->
    res.reply "\n" + JSON.stringify(robot.brain.data.searches, null, '  ')

