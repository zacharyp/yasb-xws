casper = require('casper').create
    logLevel: 'debug'
    onWaitTimeout: () ->
        true
    verbose: true
system = require('system')

# xws = '''{"description":"","faction":"empire","name":"Cheery Fel","pilots":[{"name":"rearadmiralchiraneau","points":65,"ship":"vt49decimator","upgrades":{"ept":["predator"],"crew":["ysanneisard","gunner","rebelcaptive"],"mod":["engineupgrade"]}},{"name":"soontirfel","points":35,"ship":"tieinterceptor","upgrades":{"ept":["pushthelimit"],"mod":["autothrusters","stealthdevice"],"title":["royalguardtie"]}}],"points":100,"vendor":{"yasb":{"builder":"(Yet Another) X-Wing Miniatures Squad Builder","builder_url":"https://geordanr.github.io/xwing/","link":"https://geordanr.github.io/xwing/?f=Galactic%20Empire&d=v3!s!99:57,-1,102,21,46,-1:-1:3:;28:18:5:15:M.1"}},"version":"0.2.0"}'''

casper.start 'https://geordanr.github.io/xwing', ->
    casper.log 'Waiting for from-xws to be visible...', 'debug'
    @waitUntilVisible '.from-xws'
    casper.log 'Clicking from-xws', 'debug'
    @click '.from-xws'
.then ->
    casper.log 'Waiting for xws-content to be visible...', 'debug'
    @waitUntilVisible '.xws-content'
    casper.log 'Writing XWS to textarea', 'debug'
    @evaluate (txt) ->
        $('.xws-content').val txt
    , system.stdin.read()
    casper.log 'Clicking import-xws', 'debug'
    @click '.import-xws'
.then ->
    casper.log 'Waiting for xws-content...', 'debug'
    @waitWhileVisible '.xws-content'
.then ->
    casper.log 'Returning permalink', 'debug'
    console.log @evaluate ->
        $('a.permalink:visible').attr('href')

casper.run()
