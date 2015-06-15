ViewerDetails = require './ViewerDetails'
debug = require('debug')('meshblu-aim')
EVENT_AUDIENCE_DETAILS = 131
EVENT_VIEWER = 135

class AimMessage
  constructor: () ->
    @viewerDetails = new ViewerDetails

  parse: (data) =>
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

    if result.type == EVENT_AUDIENCE_DETAILS || result.type == EVENT_VIEWER
      result = @getAudienceDetails payload, result
    else
      result.payload = payload

    return result

  getAudienceDetails: (data, result) =>

    if data.length % 20 != 0
      result.payloadInfo = data.readUInt8 0
      debug 'payloadInfo =', result.payloadInfo
      data = data.slice 1, data.length

    result.details = []

    while [ data, details ] = @viewerDetails.parse data
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
