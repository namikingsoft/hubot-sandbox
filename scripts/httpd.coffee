module.exports = (robot) ->

  robot.router.get '/', (req, res) ->
    res.type 'html'
    res.send "Hubot Homepage"
