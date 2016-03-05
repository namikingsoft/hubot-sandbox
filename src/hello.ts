import {Robot, Response} from 'hubot'

module.exports = (robot: Robot<any>) => {

  robot.hear(/hello/i, (res: Response) => {
    res.send("world")
  })
}
