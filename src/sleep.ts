import {Robot, Response} from 'hubot'
import Config from './config/Sleep'

module.exports = (robot: Robot<any>) => {

  // when wakeup
  const timerId = setInterval(() => {
    if (robot && typeof robot.send === 'function') {
      robot.messageRoom(Config.MENTION_ROOM, 'おはよう。')
      clearInterval(timerId)
    }
  }, 1000)

  // when sleep
  process.on('SIGTERM', () => {
    robot.messageRoom(Config.MENTION_ROOM, 'おやすみ。')
    setTimeout(process.exit, 1000)
  })
}
