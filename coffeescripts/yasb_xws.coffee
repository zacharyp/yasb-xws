exportObj = exports ? this

class exportObj.ListJugglerAPI
    constructor: (url) ->
        @url = url

        @initSelect2()
        @initHandlers()

    initSelect2: ->
        $('#tourney_id').select2
            placeholder: "Select a tournament"
            minimumInputLength: 1
            ajax:
                url: "/api/v1/search/tournaments"
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
            initSelection: (elem, cb) ->
                $(elem).select2 'enable', false
                init_tourney_id = elem.val()
                $.get("/api/v1/tournament/#{parseInt init_tourney_id}")
                .done (data) ->
                    $('#player_id').select2 'enable', true
                    cb
                        id: init_tourney_id
                        text: "#{data.tournament.name} / #{data.tournament.date}"
                .fail ->
                    $('#tourney_id').select2 'data', null
                .always ->
                    $('#tourney_id').select2 'enable', true

        $('#player_id').select2
            placeholder: "Select already registered player"
            allowClear: true
            query: (q) ->
                $.get("/api/v1/tournament/#{$('#tourney_id').val()}/players")
                .done (data) ->
                    if q.term == ''
                        results = ({id: player.id, text: player.name} for player in data.players)
                    else
                        results = ({id: player.id, text: player.name} for player in data.players when player.name.toLocaleLowerCase().indexOf(q.term.toLocaleLowerCase()) != -1)
                    q.callback
                        results: results

        $('#player_id').select2 'enable', false

    initHandlers: ->
        $('#tourney_id').on 'change', (e) ->
            $('#player_id').select2 'data', null
            $('#player_id').select2 'enable', true

        $('#add-list').click (e) =>
            return if $('#add-list').hasClass 'disabled'
            $('#add-list').addClass 'disabled'
            $('#add-list').text ''
            $('#add-list').append """<i class="fa fa-spin fa-circle-o-notch"></i>"""
            $('#add-list').append "&nbsp;Submitting List..."
            $('.has-error').removeClass 'has-error has-feedback'
            hideAlert()

            # generate XWS
            $.get("/#{window.location.search}")
            .done (xws) =>
                tourney_id = $('#tourney_id').val()
                email = $.trim $('#email').val()
                player_id = $('#player_id').val()
                player_name = $.trim $('#player_name').val()
                do (tourney_id, email, player_id, player_name) =>
                    if tourney_id != '' and email != '' and (player_id != '' or player_name != '')
                        # Check token validity
                        $.post("/api/v1/tournament/#{tourney_id}/token", {email: email})
                        .done (data, textStatus, jqXHR) =>
                            # token is good, post it
                            api_token = data.api_token

                            if player_name != ''
                                # add new player
                                $.ajax "/api/v1/tournament/#{tourney_id}/players",
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
                                .fail (jqXHR, textStatus, errorThrown) ->
                                    showAlert "Could not add new player #{player_name}: #{errorThrown}"
                                .always ->
                                    resetSubmitButton()
                            else
                                # update existing player
                                $.ajax "/api/v1/tournament/#{tourney_id}/player/#{player_id}",
                                    method: 'POST'
                                    contentType: 'application/json'
                                    data: JSON.stringify
                                        api_token: api_token
                                        xws: xws
                                .done =>
                                    @updateSessionAndRedirect tourney_id, email
                                .fail (jqXHR, textStatus, errorThrown) ->
                                    showAlert "Could not add list: #{errorThrown}"
                                .always ->
                                    resetSubmitButton()
                        .fail (jqXHR, textStatus, errorThrown) ->
                            # bad email
                            $('#email').parent().addClass 'has-error has-feedback'
                            showAlert 'Incorrect email for that tournament.'
                        .always ->
                            resetSubmitButton()
                    else
                        switch
                            when tourney_id == ''
                                showAlert 'No tournament selected.'
                                $('label[for="#tourney_id"]').parent().addClass('has-error')
                            when email == ''
                                showAlert 'No email entered.'
                                $('#email').parent().addClass 'has-error has-feedback'
                            when player_id == '' or player_name == ''
                                showAlert 'Player not selected and no player name entered.'
                                $('#player_name').parent().addClass 'has-error has-feedback'
                                $('label[for="#player_id"]').parent().addClass('has-error')
                            else
                                throw new Error('Uncaught condition')
                        resetSubmitButton()
            .fail ->
                showAlert 'Could not convert squadron to XWS format.'
            .always ->
                resetSubmitButton()

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

hideAlert = ->
    $('#alert').addClass 'hidden'

showAlert = (text) ->
    $('#alert').text text
    $('#alert').removeClass 'hidden'

resetSubmitButton = ->
    $('#add-list').text 'Submit List to List Juggler'
    $('#add-list').removeClass 'disabled'
