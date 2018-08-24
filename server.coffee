path = require 'path'
childProcess = require 'child_process'
express = require 'express'
morgan = require 'morgan'
session = require 'cookie-session'
bodyparser = require 'body-parser'
request = require 'request'
cors = require 'cors'
xws = require './xws'

app = exports.app = express()

app.set 'port', process.env.PORT ? (if 'production' == app.get('env') then 80 else 3000)
app.set 'view engine', 'jade'
app.set 'juggler_api_url', process.env.JUGGLER_API_URL ? 'http://localhost:5000'

# Proxy API calls to List Juggler
# This MUST be the first middleware!
app.use '/api', (req, res) ->
    proxy_url = "#{app.get 'juggler_api_url'}#{req.originalUrl}"
    proxy_req = request(proxy_url)
        .on 'error', (err) ->
            res.status(500).json
                error: "Could not proxy to API: #{err}"
    req.pipe(proxy_req).pipe(res)

app.use cors()
app.use morgan('dev')
app.use session
    secret: process.env.SECRET ? 'dev'
    expires: new Date('2038-03-14')
app.use express.static(__dirname + '/bower_components')
app.use express.static(__dirname + '/javascripts')
app.use bodyparser.json()

app.get '/', (req, res) ->
    if req.query.f? and req.query.d?
        xws_obj = xws.serializedToXWS {
          faction: req.query.f
          serialized: req.query.d
          name: req.query.sn
          obstacles: req.query.obs
        }
        xws_obj.vendor.yasb.link = "https://raithos.github.io/xwing#{req.originalUrl}"
        res.json xws_obj
    else
        res.json
            message: "Put YASB permalink query string in URL"

app.post '/', (req, res) ->
    casper_bin_path = path.join __dirname, 'node_modules', '.bin', 'casperjs'
    child_args = [
        path.join(__dirname, 'headless.coffee'),
    ]
    child = childProcess.execFile casper_bin_path, child_args, (err, stdout, stderr) ->
        if err?
            console.error(err)
            res.status(400).json
                message: err
                stdout: stdout
                stderr: stderr
        else
            res.json
                url: stdout.trim()
    child.stdin.write JSON.stringify(req.body)
    child.stdin.end()

app.get '/juggler', (req, res) ->
    if req.query.f? and req.query.d?
        xws_obj = xws.serializedToXWS
            faction: req.query.f
            serialized: req.query.d
            name: req.query.sn ? 'Unnamed'
            obstacles: req.query.obs
        res.render 'juggler',
            last_tourney_id: req.session.tourney_id ? ''
            last_email: req.session.email ? ''
            juggler_api_url: app.get 'juggler_api_url'
            list_info: "(#{xws_obj.faction}) #{(pilot.name for pilot in xws_obj.pilots).join ', '}"
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
