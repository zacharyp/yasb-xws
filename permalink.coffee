cards = require('./xwing/coffeescripts/cards-common').basicCardData()

exportObj = exports ? this

SERIALIZATION_CODE_TO_MAP =
    'U': cards.upgradesById
    'u': cards.upgradesById

SERIALIZATION_CODE_TO_SLOT =
    'U': 'upgrade'
    'u': 'upgrade'

exportObj.serializedToShips = (faction, serialized) ->
    ships = []
    re = /^v(\d+)!(.*)/
    matches = re.exec serialized
    if matches?
        # versioned
        version = parseInt matches[1]
        switch version
            when 3, 4, 5
                [ game_type_abbrev, serialized_ships ] = matches[2].split('!')
                for serialized_ship in serialized_ships.split(';')
                    unless serialized_ship == ''
                        ships.push fromSerialized(version, serialized_ship)
            when 2
                for serialized_ship in matches[2].split(';')
                    unless serialized_ship == ''
                        ships.push (fromSerialized version, serialized_ship)
    else
        # v1 (unversioned)
        for serialized_ship in serialized.split(';')
            unless serialized == ''
                ships.push (fromSerialized 1, serialized_ship)

    ships

fromSerialized = (version, serialized) ->
    ship =
        pilot: null
        upgrades: []
        modifications: []
        title: null
    switch version
        when 1
            # PILOT_ID:UPGRADEID1,UPGRADEID2:TITLEID:TITLEUPGRADE1,TITLEUPGRADE2:MODIFICATIONID
            [ pilot_id, upgrade_ids, title_id, title_conferred_upgrade_ids, modification_id ] = serialized.split ':'

            try
                ship.pilot = cards.pilotsById[parseInt(pilot_id)]
            catch e
                return null

            for upgrade_id, i in upgrade_ids.split ','
                try
                    upgrade_id = parseInt upgrade_id
                    ship.upgrades.push(cards.upgradesById[upgrade_id]) if upgrade_id >= 0
                catch e
                    ''

            try
                title_id = parseInt title_id
                ship.title = cards.titlesById[title_id] if title_id >= 0
            catch e
                ''

            if ship.title? and ship.title.conferredAddons.length > 0
                for upgrade_id, i in title_conferred_upgrade_ids.split ','
                    try
                        upgrade_id = parseInt upgrade_id
                        ship.upgrades.push(cards.upgradesById[upgrade_id]) if upgrade_id >= 0
                    catch e
                        ''

            try
                modification_id = parseInt modification_id
                ship.modifications.push(cards.modificationsById[modification_id]) if modification_id >= 0
            catch e
                ''

        when 2, 3, 4, 5
            # PILOT_ID:UPGRADEID1,UPGRADEID2:TITLEID:MODIFICATIONID:CONFERREDADDONTYPE1.CONFERREDADDONID1,CONFERREDADDONTYPE2.CONFERREDADDONID2
            if (serialized.split ':').length == 3
                [ pilot_id, upgrade_ids, conferredaddon_pairs ] = serialized.split ':'
            else
                [ pilot_id, upgrade_ids, version_4_compatibility_placeholder_title, version_4_compatibility_placeholder_mod, conferredaddon_pairs ] = serialized.split ':'
            try
                ship.pilot = cards.pilotsById[parseInt(pilot_id)]
            catch e
                return null

            for upgrade_id, i in upgrade_ids.split ','
                try
                    upgrade_id = parseInt upgrade_id
                    ship.upgrades.push(cards.upgradesById[upgrade_id]) if upgrade_id >= 0
                catch e
                    ''

            if conferredaddon_pairs?
                conferredaddon_pairs = conferredaddon_pairs.split ','
            else
                conferredaddon_pairs = []

            for conferredaddon_pair, i in conferredaddon_pairs
                [ addon_type_serialized, addon_id ] = conferredaddon_pair.split '.'
                try
                    conferred_addon = SERIALIZATION_CODE_TO_MAP[addon_type_serialized][parseInt addon_id]
                    conferred_addon.slot = SERIALIZATION_CODE_TO_SLOT[addon_type_serialized] unless conferred_addon.slot?
                    ship.upgrades.push conferred_addon
                catch e
                    ''

    ship
