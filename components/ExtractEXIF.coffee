noflo = require 'noflo'
ExifImage = require('exif').ExifImage

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'cog'
  c.description = 'Extract EXIF data from a file or buffer'

  c.inPorts.add 'in',
    datatype: 'object'
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'out'
    async: true
    forwardGroups: true
  , (input, groups, out, callback) ->
    try
      new ExifImage
        image: input
        (err, data) ->
          return callback err if err
          # TODO: Strip buffers and check if there's data
          out.send data
          do callback
    catch error
      return callback error

  c
