require! <[http domain request]>

copyHeaders = <[Date Last-Modified Expires Cache-Control Pragma Content-Length Content-Type]>

handler = (url, res, req) ->
  d = domain.create!
    ..on \error, (e) -> res.status-code 500 .end((e or "500").toString!)
    ..add req
    ..add res
  <- d.run
  bufs = []
  data = ""
  req.on \data, -> bufs.push it
  <- req.on \end, _
  data = Buffer.concat bufs .toString!
  res
    ..set-timeout 25000
    ..set-header 'Access-Control-Allow-Origin', '*'
    ..set-header 'Access-Control-Allow-Credentials', false
    ..set-header 'Access-Control-Allow-Headers', 'Content-Type'
    ..set-header 'Expires', new Date(Date.now() + 86400000).toUTCString!
  try
    r = request do
      url: url
      method: req.method
      encoding: null
      form: data
      rejectUnauthorized: false
    r.pipefilter = (rres, des) ->
      for h in rres.headers => des.remove-header h
      for h in copy-headers =>
        if rres.headers[h.to-lower-case!] => res.set-header h, that
    r.pipe res
  catch e
    res.end (e or "500").toString!

module.exports = handler
