import * as hello from 'hello'
import {Robot, Response, TextMessage} from 'hubot'
const assert = require('power-assert')


describe('hello', function() {

  let robot: Robot
  let user: any

  beforeEach(done => {
    robot = new Robot(null, 'mock-adapter', false, 'TestHubot')
    robot.adapter.on('connected', () => {
      hello(robot)
      user = robot.brain.userForId('1', {
        name: 'mocha',
        room: '#general',
      })
      done()
    })
    robot.run()
  })

  afterEach(() => robot.shutdown())

  context('when received hello', () => {
    it('should be send world ', done => {
      robot.adapter.on('reply', (envelope, strings) => {
        assert(envelope.user.name === 'mocha')
        assert(strings[0] === 'world')
        done()
      })
      robot.adapter.receive(new TextMessage(user, 'hello'))
    })
  })
})
