path = require 'path'
childProcess = require 'child_process'
express = require 'express'
session = require 'cookie-session'
bodyparser = require 'body-parser'
request = require 'request'
xws = require './xws'
xws_yasb = require('./xws-yasb')

app = exports.app = express()

app.set 'port', process.env.PORT ? (if 'production' == app.get('env') then 80 else 3000)
app.set 'juggler_api_url', process.env.JUGGLER_API_URL ? 'http://localhost:5000'

app.use session
    secret: process.env.SECRET ? 'dev'
    expires: new Date('2038-03-14')
app.use bodyparser.json()

app.get '/', (req, res) ->
    if req.query.f? and req.query.d?
        xws_obj = xws.serializedToXWS {
          faction: req.query.f
          serialized: req.query.d
          name: req.query.sn
          obstacles: req.query.obs
        }
        xws_obj.vendor.yasb.link = "https://raithos.github.io#{req.originalUrl}"

        res.header("Access-Control-Allow-Origin", "*");
        res.type('application/json')

        res.json xws_obj
    else
        res.json
            message: "Put YASB permalink query string in URL"

app.post '/reverse', (req, res) ->
    try
        xwsString = JSON.stringify(req.body);
        result = await xws_yasb.covert_xws(xwsString)

        res.header("Access-Control-Allow-Origin", "*");
        res.type('application/json')

        res.json
            url: result
    catch err
        res.status(400).json
            message: err


app.listen app.get('port')
console.log "Listening on port #{app.get 'port'}..."
