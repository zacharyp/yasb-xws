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

    initHandlers: ->
        $('#add-list').click (e) =>
            return if $('#add-list').hasClass 'disabled'
            $('#add-list').addClass 'disabled'
            $('#add-list').text 'Submitting...'

            # generate XWS
            $.get("/#{window.location.search}")
            .done (xws) =>
                tourney_id = $('#tourney_id').val()
                email = $('#email').val()
                player_id = $('#player_id').val()
                player_name = $('#player-name').val()
                do (tourney_id, email, player_id, player_name) =>
                    if tourney_id != '' and email != '' and (player_id != '' or player_name != '')
                        # Check token validity
                        $.post("#{@url}/api/v1/tournament/#{tourney_id}/token", {email: email})
                        .done (data, textStatus, jqXHR) =>
                            # token is good, post it
                            api_token = data.api_token

                            if player_name != ''
                                # add new player
                                $.ajax "#{@url}/api/v1/tournament/#{tourney_id}/players",
                                    method: 'PUT'
                                    contentType: 'application/json'
                                    data: JSON.stringify
                                        api_token: api_token
                                        players: [
                                            {
                                                name: player_name
                                                xws: xws
                                            }
                                        ]
                                .done =>
                                    @updateSessionAndRedirect tourney_id, email
                            else
                                # update existing player
                                $.ajax "#{@url}/api/v1/tournament/#{tourney_id}/player/#{player_id}",
                                    method: 'POST'
                                    contentType: 'application/json'
                                    data: JSON.stringify
                                        api_token: api_token
                                        xws: xws
                                .done =>
                                    @updateSessionAndRedirect tourney_id, email
                        .fail (jqXHR, textStatus, errorThrown) ->
                            # bad email
                            alert "Access denied: wrong email - #{errorThrown}"
            .fail ->
                alert "Invalid squadron"

    updateSessionAndRedirect: (tourney_id, email) ->
        # save tourney id and email
        $.ajax '/juggler',
            method: 'POST'
            contentType: 'application/json'
            data: JSON.stringify
                tourney_id: tourney_id
                email: email
        .done =>
            window.location.href = "#{@url}/get_tourney_details?tourney_id=#{tourney_id}"
