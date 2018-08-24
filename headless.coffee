casper = require('casper').create
    onWaitTimeout: () ->
        true
    waitTimeout: 500
system = require('system')

# xws = '''{"description":"","faction":"empire","name":"Cheery Fel","pilots":[{"name":"rearadmiralchiraneau","points":65,"ship":"vt49decimator","upgrades":{"ept":["predator"],"crew":["ysanneisard","gunner","rebelcaptive"],"mod":["engineupgrade"]}},{"name":"soontirfel","points":35,"ship":"tieinterceptor","upgrades":{"ept":["pushthelimit"],"mod":["autothrusters","stealthdevice"],"title":["royalguardtie"]}}],"points":100,"vendor":{"yasb":{"builder":"(Yet Another) X-Wing Miniatures Squad Builder","builder_url":"https://raithos.github.io/xwing/","link":"https://raithos.github.io/xwing/?f=Galactic%20Empire&d=v3!s!99:57,-1,102,21,46,-1:-1:3:;28:18:5:15:M.1"}},"version":"0.2.0"}'''

casper.start 'https://raithos.github.io/xwing', ->
    @waitUntilVisible '.from-xws'
    @click '.from-xws'
.then ->
    @waitUntilVisible '.xws-content'
    @evaluate (txt) ->
        $('.xws-content').val txt
    , system.stdin.read()
    @click '.import-xws'
.then ->
    if @visible('.xws-content')
        @waitWhileVisible '.xws-content'
.then ->
    console.log @evaluate ->
        $('a.permalink:visible').attr('href')

casper.run()
