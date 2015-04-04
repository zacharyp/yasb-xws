var exportObj,
  hasProp = {}.hasOwnProperty;

exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

exportObj.ListJugglerAPI = (function() {
  function ListJugglerAPI(url) {
    this.url = url;
  }

  ListJugglerAPI.prototype.initSelect2 = function() {
    $('#tourney_id').select2({
      placeholder: "Select a tournament",
      minimumInputLength: 1,
      ajax: {
        url: this.url + "/api/v1/search/tournaments",
        type: 'POST',
        dataType: 'json',
        quietMillis: 250,
        data: function(term, page) {
          return {
            query: term
          };
        },
        results: function(data, page) {
          var info, result_ary, tourney_id;
          result_ary = [];
          for (tourney_id in data) {
            if (!hasProp.call(data, tourney_id)) continue;
            info = data[tourney_id];
            result_ary.push({
              id: parseInt(tourney_id),
              text: info.name + " / " + info.venue + " / " + info.date
            });
          }
          return {
            results: result_ary
          };
        }
      },
      initSelection: (function(_this) {
        return function(elem, cb) {
          var init_tourney_id;
          init_tourney_id = elem.val();
          if (init_tourney_id !== '') {
            return $.get(_this.url + "/api/v1/tournament/" + (parseInt(init_tourney_id))).done(function(data) {
              return cb({
                id: init_tourney_id,
                text: data.tournament.name + " / " + data.tournament.date
              });
            });
          }
        };
      })(this)
    });
    $('#tourney_id').on('change', function(e) {
      return $('#player_id').select2('data', null);
    });
    return $('#player_id').select2({
      placeholder: "Select player",
      query: (function(_this) {
        return function(q) {
          return $.get(_this.url + "/api/v1/tournament/" + ($('#tourney_id').val()) + "/players").done(function(data) {
            var player, results;
            if (q.term === '') {
              results = (function() {
                var i, len, ref, results1;
                ref = data.players;
                results1 = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  player = ref[i];
                  results1.push({
                    id: player.id,
                    text: player.name
                  });
                }
                return results1;
              })();
            } else {
              results = (function() {
                var i, len, ref, results1;
                ref = data.players;
                results1 = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  player = ref[i];
                  if (player.name.toLocaleLowerCase().indexOf(q.term.toLocaleLowerCase()) !== -1) {
                    results1.push({
                      id: player.id,
                      text: player.name
                    });
                  }
                }
                return results1;
              })();
            }
            return q.callback({
              results: results
            });
          });
        };
      })(this)
    });
  };

  ListJugglerAPI.prototype.initHandlers = function() {
    return $('#add-list').click((function(_this) {
      return function(e) {
        if ($('#add-list').hasClass('disabled')) {
          return;
        }
        $('#add-list').addClass('disabled');
        $('#add-list').text('Submitting...');
        return $.get("/" + window.location.search).done(function(xws) {
          var email, player_id, player_name, tourney_id;
          tourney_id = $('#tourney_id').val();
          email = $('#email').val();
          player_id = $('#player_id').val();
          player_name = $('#player-name').val();
          return (function(tourney_id, email, player_id, player_name) {
            if (tourney_id !== '' && email !== '' && (player_id !== '' || player_name !== '')) {
              return $.post(_this.url + "/api/v1/tournament/" + tourney_id + "/token", {
                email: email
              }).done(function(data, textStatus, jqXHR) {
                var api_token;
                api_token = data.api_token;
                if (player_name !== '') {
                  return $.ajax(_this.url + "/api/v1/tournament/" + tourney_id + "/players", {
                    method: 'PUT',
                    contentType: 'application/json',
                    data: JSON.stringify({
                      api_token: api_token,
                      players: [
                        {
                          name: player_name,
                          xws: xws
                        }
                      ]
                    })
                  }).done(function() {
                    return _this.updateSessionAndRedirect(tourney_id, email);
                  });
                } else {
                  return $.ajax(_this.url + "/api/v1/tournament/" + tourney_id + "/player/" + player_id, {
                    method: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify({
                      api_token: api_token,
                      xws: xws
                    })
                  }).done(function() {
                    return _this.updateSessionAndRedirect(tourney_id, email);
                  });
                }
              }).fail(function(jqXHR, textStatus, errorThrown) {
                return alert("Access denied: wrong email - " + errorThrown);
              });
            }
          })(tourney_id, email, player_id, player_name);
        }).fail(function() {
          return alert("Invalid squadron");
        });
      };
    })(this));
  };

  ListJugglerAPI.prototype.updateSessionAndRedirect = function(tourney_id, email) {
    return $.ajax('/juggler', {
      method: 'POST',
      contentType: 'application/json',
      data: JSON.stringify({
        tourney_id: tourney_id,
        email: email
      })
    }).done((function(_this) {
      return function() {
        return window.location.href = _this.url + "/get_tourney_details?tourney_id=" + tourney_id;
      };
    })(this));
  };

  return ListJugglerAPI;

})();

//# sourceMappingURL=yasb_xws.js.map
