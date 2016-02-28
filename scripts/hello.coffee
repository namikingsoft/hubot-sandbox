module.exports = (robot) ->

  robot.hear /hello/i, (res) ->
    res.send "world"
