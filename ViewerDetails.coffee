class ViewerDetails
  constructor: () ->

  parse: (data) =>
    if data.length < 20
      return [null,null]
    result = {}
    result.id = data.readUInt32BE 0
    result.gender = data.readUInt8 4
    result.age = data.readUInt8 5
    result.viewingTime = data.readUInt32BE 8
    result.topLeftX = data.readUInt16BE 12
    result.topLeftY = data.readUInt16BE 14
    result.faceWidth = data.readUInt16BE 16
    result.faceHeight = data.readUInt16BE 18

    return [ data.slice(20, data.length), result ]

module.exports = ViewerDetails
