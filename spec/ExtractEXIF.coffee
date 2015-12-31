noflo = require 'noflo'
chai = require 'chai' unless chai
ExtractEXIF = require '../components/ExtractEXIF.coffee'

describe 'ExtractEXIF component', ->
  c = null
  ins = null
  out = null
  error = null
  beforeEach (done) ->
    c = ExtractEXIF.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out
    c.outPorts.error.attach error
    done()
  afterEach (done) ->
    c.inPorts.in.detach ins
    c.outPorts.out.detach out
    c.outPorts.error.detach error
    ins = null
    out = null
    error = null
    done()

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
    it 'should have an error port', ->
      chai.expect(c.outPorts.error).to.be.an 'object'

  describe 'when passed a missing file path', ->
    it 'should send an empty object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data).to.deep.equal {}
        done()
      ins.send 'nonono'

  describe 'when passed a non-JPEG image', ->
    it 'should send an empty object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data).to.deep.equal {}
        done()

      filePath = 'spec/fixtures/no-jpeg.png'
      ins.send filePath

  describe 'when passed an image without EXIF data', ->
    it 'should send an empty object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data).to.deep.equal {}
        done()

      filePath = 'spec/fixtures/no-exif.jpg'
      ins.send filePath

  describe 'when passed an image with EXIF data', ->
    it 'should extract EXIF data', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.image).to.exists
        chai.expect(data.thumbnail).to.exists
        chai.expect(data.exif).to.exists
        chai.expect(data.gps).to.exists
        chai.expect(data.interoperability).to.exists
        chai.expect(data.makernote).to.exists
        done()

      filePath = 'spec/fixtures/with-exif.jpg'
      ins.send filePath

    it 'should strip buffers from EXIF data', (done) ->
      out.on 'data', (data) ->
        chai.expect(data.exif['ExifVersion']).to.not.exists
        chai.expect(data.interoperability['InteropVersion']).to.not.exists
        done()

      filePath = 'spec/fixtures/with-exif.jpg'
      ins.send filePath

  describe 'when passed an image from Olympus camera with bad makernote', ->
    it 'should extract EXIF data', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.image).to.exists
        chai.expect(data.thumbnail).to.exists
        chai.expect(data.exif).to.exists
        chai.expect(data.gps).to.exists
        chai.expect(data.interoperability).to.exists
        chai.expect(data.makernote).to.exists
        done()

      filePath = 'spec/fixtures/evil.jpg'
      ins.send filePath

    it 'should strip buffers from EXIF data', (done) ->
      out.on 'data', (data) ->
        chai.expect(data.exif['ExifVersion']).to.not.exists
        chai.expect(data.interoperability['InteropVersion']).to.not.exists
        done()

      filePath = 'spec/fixtures/evil.jpg'
      ins.send filePath
