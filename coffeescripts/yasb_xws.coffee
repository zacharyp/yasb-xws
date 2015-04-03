exportObj = exports ? this

class exportObj.ListJugglerAPI
    constructor: (url) ->
        @url = url

    initSelect2: ->
        $('#tourney_id').select2
            placeholder: "Select a tournament"
            minimumInputLength: 1
            ajax:
                url: "#{@url}/api/v1/search/tournaments"
                type: 'POST'
                dataType: 'json'
                quietMillis: 250
                data: (term, page) ->
                    query: term
                results: (data, page) ->
                    result_ary = []
                    for own tourney_id, info of data
                        result_ary.push
                            id: parseInt tourney_id
                            text: "#{info.name} / #{info.venue} / #{info.date}"
                    results: result_ary
            initSelection: (elem, cb) =>
                init_tourney_id = elem.val()
                if init_tourney_id != ''
                    $.get("#{@url}/api/v1/tournament/#{parseInt init_tourney_id}")
                        .done (data) ->
                            cb
                                id: init_tourney_id
                                text: "#{data.tournament.name} / #{data.tournament.date}"

        $('#tourney_id').on 'change', (e) ->
            $('#player_id').select2 'data', null

        $('#player_id').select2
            placeholder: "Select player"
            query: (q) =>
                $.get("#{@url}/api/v1/tournament/#{$('#tourney_id').val()}/players")
                    .done (data) ->
                        if q.term == ''
                            results = ({id: player.id, text: player.name} for player in data.players)
                        else
                            results = ({id: player.id, text: player.name} for player in data.players when player.name.toLocaleLowerCase().indexOf(q.term.toLocaleLowerCase()) != -1)
                        q.callback
                            results: results
