noflo = require 'noflo'
ExifImage = require('exif').ExifImage

# @runtime noflo-nodejs

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'image'
  c.description = 'Extract EXIF data from a file or buffer'

  c.inPorts.add 'in',
    datatype: 'object'
    description: 'Image filepath or buffer'
  c.outPorts.add 'out',
    datatype: 'string'
    description: 'Extracted EXIF data'
  c.outPorts.add 'error',
    datatype: 'object'
    description: 'Errors'

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
          for high_key,high_value of data
            for low_key,low_value of high_value
              # Strip out buffers
              if Buffer.isBuffer low_value
                delete data[high_key][low_key]
              # Sanitize against \u0000
              if typeof low_value is 'string'
                data[high_key][low_key] = low_value.replace /\\u0000/g, ''
          out.send data
          do callback
    catch error
      return callback error

  c
