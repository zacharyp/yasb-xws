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

  return ListJugglerAPI;

})();

//# sourceMappingURL=yasb_xws.js.map
