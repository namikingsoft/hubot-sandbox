FeedParser = require 'feedparser'
Request = require 'request'
_ = require 'lodash'

MENTION_ROOM = process.env.FEED_MENTION_ROOM || "#general"
MAX_FETCH_COUNT = 5
MAX_SHOWN_LIST_COUNT = 1000

module.exports = (robot) ->

  message_queue = []

  send = ->
    if message_queue.length > 0
      message = message_queue.shift()
      robot.messageRoom MENTION_ROOM, message

  fetch = ->
    feed_list = robot.brain.data.feed_list
    shown_list = robot.brain.data.feed_shown_list
    for row, i in feed_list
      do (row, i) ->
        fetch_count = 0
        request = Request
          url: row.url
          headers:
            'User-Agent': 'Opera/9.80 (Windows NT 5.1; U; ja) Presto/2.7.62 Version/11.01'
        request.on 'error', (err) ->
          console.log "Error fetch url: #{err}"
        request.on 'response', (res) ->
          if res.statusCode isnt 200
            return this.emit 'error', new Error('Bad status code')
          @pipe feedparser
        feedparser = new FeedParser
        feedparser.on 'error', (err) ->
          console.log "Error fetch url: #{err}"
        feedparser.on 'readable', ->
          while (item = @read()) and fetch_count < MAX_FETCH_COUNT
            feed = @meta.title
            title = item.title
            link = item.link
            if _.find(shown_list, (x) -> x is link)
              shown_list = _.filter(shown_list, (x) -> x isnt link)
              shown_list.push link
              continue
            fetch_count++
            message = "#{title} - #{feed}\n#{link}"
            message_queue.push message
            # add link on shown list
            shown_list.push link
            shown_list.shift() while shown_list.length > MAX_SHOWN_LIST_COUNT
          # save new shown list
          robot.brain.data.feed_shown_list = shown_list

  robot.brain.on 'loaded', ->
    robot.brain.data.feed_list ||= []
    robot.brain.data.feed_shown_list ||= []
    setInterval send, 1000 * 10
    setInterval fetch, 1000 * 60

  robot.respond /feed fetch/i, -> fetch()

  robot.respond /feed reset/i, (res) ->
    robot.brain.data.feed_list = []
    res.reply "OK. Search list was cleared"

  robot.respond /feed add ([a-zA-Z0-9_]+) (.*)/i, (res) ->
    name = res.match[1]
    url = res.match[2]
    robot.brain.data.feed_list.push
      name: name
      url: url
    res.reply "Added: #{name} -> #{url}"

  robot.respond /feed rm ([a-zA-Z0-9_]+)/i, (res) ->
    name = res.match[1]
    robot.brain.data.feed_list = robot.brain.data.feed_list.filter (row) ->
      row.name != name
    res.reply "Removed: #{name}"

  robot.respond /feed list/i, (res) ->
    res.reply "\n" + JSON.stringify(robot.brain.data.feed_list, null, '  ')
