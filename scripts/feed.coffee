FeedParser = require 'feedparser'
Request = require 'request'
_ = require 'lodash'

MENTION_ROOM = process.env.FEED_MENTION_ROOM || "#general"
MAX_FETCH_COUNT = 5

module.exports = (robot) ->

  message_queue = []

  send = ->
    if message_queue.length > 0
      message = message_queue.shift()
      robot.messageRoom MENTION_ROOM, message

  fetch = ->
    fetches = robot.brain.data.fetches
    for row, i in fetches
      do (row, i) ->
        fetch_count = 0
        request = Request row.url
        request.on 'error', (err) ->
          console.log "Error fetch url: #{err}"
        request.on 'response', (res) ->
          stream = @
          if res.statusCode != 200
            return this.emit 'error', new Error('Bad status code')
          stream.pipe feedparser
        feedparser = new FeedParser
        feedparser.on 'error', (err) ->
          console.log "Error fetch url: #{err}"
        feedparser.on 'readable', ->
          while (item = @read()) and fetch_count < MAX_FETCH_COUNT
            feed = @meta.title
            title = item.title
            link = item.link
            continue if _.find row.shown_list, (x) -> x is link
            message = "#{title}\n#{feed}\n#{link}"
            message_queue.push message
            fetch_count++
            # add link on shown list
            row.shown_list.push link
            row.shown_list.shift() while row.shown_list.length > 5
          # save
          robot.brain.data.fetches[i] = row

  robot.brain.on 'loaded', ->
    robot.brain.data.fetches ||= []
    setInterval send, 1000 * 5

  robot.respond /feed fetch/i, -> fetch()

  robot.respond /feed reset/i, (res) ->
    robot.brain.data.fetches = []
    res.reply "OK. Search list was cleared"

  robot.respond /feed add ([a-zA-Z0-9_]+) (.*)/i, (res) ->
    name = res.match[1]
    url = res.match[2]
    robot.brain.data.fetches.push
      name: name
      url: url
      shown_list: []
    res.reply "Added: #{name} -> #{url}"

  robot.respond /feed rm ([a-zA-Z0-9_]+)/i, (res) ->
    name = res.match[1]
    robot.brain.data.fetches = robot.brain.data.fetches.filter (row) ->
      row.name != name
    res.reply "Removed: #{name}"

  robot.respond /feed list/i, (res) ->
    res.reply "\n" + JSON.stringify(robot.brain.data.fetches, null, '  ')


