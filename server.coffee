express = require 'express'
morgan = require 'morgan'
session = require 'cookie-session'
bodyparser = require 'body-parser'
xws = require './xws'

app = exports.app = express()

app.set 'port', process.env.PORT ? (if 'production' == app.get('env') then 80 else 3000)
app.set 'view engine', 'jade'
app.set 'juggler_api_url', process.env.JUGGLER_API_URL ? 'http://localhost:5000'

app.use morgan('dev')
app.use session
    secret: process.env.SECRET ? 'dev'
    expires: new Date('2038-03-14')
app.use express.static(__dirname + '/bower_components')
app.use express.static(__dirname + '/javascripts')
app.use bodyparser.json()

app.get '/', (req, res) ->
    if req.query.f? and req.query.d?
        xws_obj = xws.serializedToXWS req.query.f, req.query.d
        xws_obj.vendor.yasb.link = "https://geordanr.github.io/xwing#{req.originalUrl}"
        res.json xws_obj
    else
        res.json
            message: "Put YASB permalink query string in URL"

app.get '/juggler', (req, res) ->
    if req.query.f? and req.query.d?
        res.render 'juggler',
            last_tourney_id: req.session.tourney_id ? ''
            last_email: req.session.email ? ''
            juggler_api_url: app.get 'juggler_api_url'
    else
        res.status(400).json
            message: "Put YASB permalink query string in URL"

app.post '/juggler', (req, res) ->
    req.session.tourney_id = req.body.tourney_id
    req.session.email = req.body.email

    res.json
        success: true


app.listen app.get('port')
console.log "Listening on port #{app.get 'port'}..."
