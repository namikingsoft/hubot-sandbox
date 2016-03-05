import {Robot} from 'hubot'

module.exports = (robot: Robot<any>) => {

  robot.router.get('/', (req: any, res: any) => {
    res.type('html')
    res.send("Hubot Homepage")
  })
}
