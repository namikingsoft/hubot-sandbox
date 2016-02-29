Twit = require "twit"
MENTION_ROOM = process.env.TWITTER_MENTION_ROOM || "#general"

config =
  consumer_key: process.env.TWITTER_CONSUMER_KEY
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET
  access_token: process.env.TWITTER_ACCESS_TOKEN_KEY
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET

module.exports = (robot) ->

  searchAndSend = ->
    param =
      q: 'docker lang:ja'
      count: 5
      since_id: robot.brain.data.last_tweet
    twit = new Twit config
    twit.get 'search/tweets', param, (err, data) ->
      if err
        console.log "Error getting tweets: #{err}"
        return
      if data.statuses? and data.statuses.length > 0
        robot.brain.data.last_tweet = data.statuses[0].id_str
        for tweet in data.statuses.reverse()
          text = "#{tweet.text.split(/\r?\n/).join(" ").substring(0, 40)}..."
          user = "@#{tweet.user.screen_name}"
          url = "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id_str}"
          message = "#{text} #{user}\n#{url}"
          robot.messageRoom '#general', message

  robot.brain.on 'loaded', ->
    robot.brain.data.last_tweet ||= '1'
    setInterval searchAndSend, 1000 * 20 # every 20 sec

  robot.respond /tweet/i, -> searchAndSend()
