net = require 'net'
AimMessage = require './AimMessage'
debug = require('debug')('meshblu-aim')

MESSAGE_GET_AUDIENCE_STATUS = 0
MESSAGE_GET_AUDIENCE_DETAILS = 1
MESSAGE_GET_VIEWER_EVENTS = 5

class AIM
  constructor: (@config, @callback=->) ->
    @request = new Buffer [
        0xFA, #magic word part 1
        0xCE, #magic word part 2
        0x01, #version
        MESSAGE_GET_VIEWER_EVENTS, #command
        0x01, #payload size
        0x01 #payload
      ]

    @reconnect()

  connect: () =>
    debug "connecting to AIM"
    socket = new net.Socket()
    socket.setTimeout 3000, =>
      debug 'connection to aim timed out'
      socket.destroy()
    socket.connect @config.port, @config.host, =>
      debug 'connected'
      socket.setTimeout(0)
      clearInterval(@interval)

  listenToClient: (client) =>
    return unless client

    client.on 'connect', =>
      debug "AIM connected!"
      clearInterval(@interval)
      client.write(@request, (response) -> )

    client.on 'data', (data)=>
      @callback(AimMessage.parse data)

    client.on 'end', () =>
      #var connecting = true
      debug 'aim connection closed! trying to reconnect'

      @reconnect()

    return client

  reconnect: () =>
    @interval = setInterval (=>
      debug "inside reconnect!"
      @listenToClient @connect()
    ), 3000

module.exports = AIM
