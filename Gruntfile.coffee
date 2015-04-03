module.exports = (grunt) ->
    grunt.initConfig
        coffee:
            compile:
                options:
                    bare: true
                    join: true
                    runtime: 'window'
                    sourceMap: true
                files:
                    'javascripts/yasb_xws.js': ['coffeescripts/*.coffee']
        uglify:
            compile:
                options:
                    sourceMap: true
                    sourceMapIn: 'javascripts/yasb_xws.js.map'
                files:
                    'javascripts/yasb_xws.min.js': 'javascripts/yasb_xws.js'

    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-coffee'

    grunt.registerTask 'default', [
        'coffee'
        'uglify'
    ]
