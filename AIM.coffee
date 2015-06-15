net = require 'net'
AimMessage = require './AimMessage'
debug = require('debug')('meshblu-aim')

MESSAGE_GET_AUDIENCE_STATUS = 0
MESSAGE_GET_AUDIENCE_DETAILS = 1
MESSAGE_GET_VIEWER_EVENTS = 5

class AIM
  constructor: (config, callback=->) ->

    request = new Buffer [
        0xFA, #magic word part 1
        0xCE, #magic word part 2
        0x01, #version
        MESSAGE_GET_VIEWER_EVENTS, #command
        0x01, #payload size
        0x01 #payload
      ]

    message = new AimMessage()

    client = net.connect
      host: config?.host || '192.168.100.8',
      port: config?.port || 12500, ->
        debug client.write(request, (response) ->
          debug response)

    client.on 'connect', ->
      debug "AIM connected!"

    client.on 'data', (data)->
      callback(message.parse data)

module.exports = AIM
