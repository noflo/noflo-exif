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
          # If image is unsupported or other error, send empty obj instead of
          # failing
          if err
            out.send {}
            do callback
            return
          # If image has empty EXIF data, send empty obj
          if Object.keys(data.exif).length == 0
            out.send {}
            do callback
            return
          # Strip out buffers
          for high_key,high_value of data
            for low_key,low_value of high_value
              if Buffer.isBuffer low_value
                delete data[high_key][low_key]
          out.send data
          do callback
    catch error
      return callback error

  c
