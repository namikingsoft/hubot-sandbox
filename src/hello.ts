import {Robot, Response} from 'hubot'

export = (robot: Robot<any>) => {

  robot.hear(/hello/i, (res: Response) => {
    res.send("world")
  })
}
