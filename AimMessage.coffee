ViewerDetails = require './ViewerDetails'
debug = require('debug')('meshblu-aim')
EVENT_AUDIENCE_DETAILS = 131
EVENT_AUDIENCE_STATUS = 130
EVENT_VIEWER = 135

class AimMessage
  constructor: () ->

  @parse: (data) =>
    debug "got #{data.length} bytes"
    debug "data #{data.toString('hex')}"

    result = {}
    magicWord = data.slice 0, 2

    if magicWord.toString('hex') != 'face'
      debug 'magic word does not match!'
      return {}

    result.version = data.readUInt8(2)
    result.type = data.readUInt8(3)
    payloadSize = data.readUInt8(4)
    payload = data.slice 5, data.length

    debug "MagicWord is: #{magicWord.toString('hex')}"
    debug "Version is: #{result.version}"
    debug "Type is: #{result.type}"
    debug "payload size is: #{payloadSize}"
    debug "payload: #{payload.toString('hex')} [len=#{payload.length}]"

    if payload.length % 20 != 0
      result.payloadInfo = payload.readUInt8 0
      debug 'payloadInfo =', result.payloadInfo
      payload = payload.slice 1, payload.length

    if result.type == EVENT_AUDIENCE_DETAILS || result.type == EVENT_VIEWER
      result = @getAudienceDetails payload, result
    else
      result.payload = payload

    return result

  @getAudienceDetails: (payload, result) =>

    result.details = []

    while [ payload, details ] = ViewerDetails.parse payload
      if !details
        break
      result.details.push details
      debug ' id:', details.id
      debug ' gender:', details.gender
      debug ' age:', details.age
      debug ' viewingTime:', details.viewingTime
      debug ' topLeftX:', details.topLeftX
      debug ' topLeftY:', details.topLeftY
      debug ' faceWidth:', details.faceWidth
      debug ' faceHeight:', details.faceHeight

    return result

module.exports = AimMessage
