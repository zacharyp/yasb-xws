express = require 'express'
morgan = require 'morgan'
xws = require './xws'

app = exports.app = express()

app.set 'port', process.env.PORT ? (if 'production' == app.get('env') then 80 else 3000)

app.use morgan('dev')

app.get '/', (req, res) ->
    if req.query.f? and req.query.d?
        xws_obj = xws.serializedToXWS req.query.f, req.query.d
        xws_obj.vendor.yasb.link = "https://geordanr.github.io/xwing#{req.originalUrl}"
        res.json xws_obj
    else
        res.json
            message: "Put YASB permalink query string in URL"

app.listen app.get('port')
console.log "Listening on port #{app.get 'port'}..."
