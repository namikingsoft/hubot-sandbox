# http://shokai.org/blog/archives/10108
module.exports = (robot) ->

  # when wakeup
  cid = setInterval ->
    return if typeof robot?.send isnt 'function'
    robot.send {room: "#general"}, "おはよう。"
    clearInterval cid
  , 1000

  # when sleep
  on_sigterm = ->
    robot.send {room: "#general"}, 'おやすみ。'
    setTimeout process.exit, 1000

  if process._events.SIGTERM?
    process._events.SIGTERM = on_sigterm
  else
    process.on 'SIGTERM', on_sigterm
