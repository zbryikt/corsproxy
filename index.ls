require! <[http domain request]>

port = 9000
copyHeaders = <[Date Last-Modified Expires Cache-Control Pragma Content-Length Content-Type]>

server = http.create-server (req, res) ->
  d = domain.create!
    ..on \error, (e) -> res.status-code 500 .end((e or "500").toString!)
    ..add req
    ..add res
  <- d.run
  res
    ..set-timeout 25000
    ..set-header 'Access-Control-Allow-Origin', '*'
    ..set-header 'Access-Control-Allow-Credentials', false
    ..set-header 'Access-Control-Allow-Headers', 'Content-Type'
    ..set-header 'Expires', new Date(Date.now() + 86400000).toUTCString!
  try
    r = request req.url.slice(1), {encoding: null, rejectUnauthorized: false}
    r.pipefilter = (rres, des) ->
      for h in rres.headers => des.remove-header h
      for h in copy-headers =>
        if rres.headers[h.to-lower-case!] => res.set-header h, that
    r.pipe res
  catch e
    res.end (e or "500").toString!

server.listen port
console.log "cors proxy server start @ localhost:#port"
