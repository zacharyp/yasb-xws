var exportObj, hideAlert, resetSubmitButton, showAlert,
  hasProp = {}.hasOwnProperty;

exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

exportObj.ListJugglerAPI = (function() {
  function ListJugglerAPI(url) {
    this.url = url;
    this.initSelect2();
    this.initHandlers();
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
          $(elem).select2('enable', false);
          init_tourney_id = elem.val();
          return $.get(_this.url + "/api/v1/tournament/" + (parseInt(init_tourney_id))).done(function(data) {
            $('#player_id').select2('enable', true);
            return cb({
              id: init_tourney_id,
              text: data.tournament.name + " / " + data.tournament.date
            });
          }).fail(function() {
            return $('#tourney_id').select2('data', null);
          }).always(function() {
            return $('#tourney_id').select2('enable', true);
          });
        };
      })(this)
    });
    $('#player_id').select2({
      placeholder: "Select already registered player",
      allowClear: true,
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
    return $('#player_id').select2('enable', false);
  };

  ListJugglerAPI.prototype.initHandlers = function() {
    $('#tourney_id').on('change', function(e) {
      $('#player_id').select2('data', null);
      return $('#player_id').select2('enable', true);
    });
    return $('#add-list').click((function(_this) {
      return function(e) {
        if ($('#add-list').hasClass('disabled')) {
          return;
        }
        $('#add-list').addClass('disabled');
        $('#add-list').text('');
        $('#add-list').append("<i class=\"fa fa-spin fa-circle-o-notch\"></i>");
        $('#add-list').append("&nbsp;Submitting...");
        $('.has-error').removeClass('has-error has-feedback');
        hideAlert();
        return $.get("/" + window.location.search).done(function(xws) {
          var email, player_id, player_name, tourney_id;
          tourney_id = $('#tourney_id').val();
          email = $.trim($('#email').val());
          player_id = $('#player_id').val();
          player_name = $.trim($('#player_name').val());
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
                  }).fail(function(jqXHR, textStatus, errorThrown) {
                    return showAlert("Could not add new player " + player_name + ": " + errorThrown);
                  }).always(function() {
                    return resetSubmitButton();
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
                  }).fail(function(jqXHR, textStatus, errorThrown) {
                    return showAlert("Could not add list: " + errorThrown);
                  }).always(function() {
                    return resetSubmitButton();
                  });
                }
              }).fail(function(jqXHR, textStatus, errorThrown) {
                $('#email').parent().addClass('has-error has-feedback');
                return showAlert('Incorrect email for that tournament.');
              }).always(function() {
                return resetSubmitButton();
              });
            } else {
              switch (false) {
                case tourney_id !== '':
                  showAlert('No tournament selected.');
                  $('label[for="#tourney_id"]').parent().addClass('has-error');
                  break;
                case email !== '':
                  showAlert('No email entered.');
                  $('#email').parent().addClass('has-error has-feedback');
                  break;
                case !(player_id === '' || player_name === ''):
                  showAlert('Player not selected and no player name entered.');
                  $('#player_name').parent().addClass('has-error has-feedback');
                  $('label[for="#player_id"]').parent().addClass('has-error');
                  break;
                default:
                  throw new Error('Uncaught condition');
              }
              return resetSubmitButton();
            }
          })(tourney_id, email, player_id, player_name);
        }).fail(function() {
          return showAlert('Could not convert squadron to XWS format.');
        }).always(function() {
          return resetSubmitButton();
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

hideAlert = function() {
  return $('#alert').addClass('hidden');
};

showAlert = function(text) {
  $('#alert').text(text);
  return $('#alert').removeClass('hidden');
};

resetSubmitButton = function() {
  $('#add-list').text('Add List');
  return $('#add-list').removeClass('disabled');
};

//# sourceMappingURL=yasb_xws.js.map
