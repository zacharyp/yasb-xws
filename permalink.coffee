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
    re = if "Z" in serialized then /^v(\d+)Z(.*)/ else /^v(\d+)!(.*)/
    matches = re.exec serialized
    if matches?
        # versioned
        version = parseInt matches[1]
        [ game_type_abbrev, desired_points, serialized_ships ] =
            if version > 7
                 [g, p, s] = matches[2].split('Z')
                 [g, parseInt(p), s]
            else
                [ game_type_and_point_abbrev, s ] = matches[2].split('!')
                p = parseInt(game_type_and_point_abbrev.split('=')[1])
                g = game_type_and_point_abbrev.split('=')[0]
                [ g, p, s ]
        ship_splitter = if version > 7 then 'Y' else ';'
        for serialized_ship in serialized_ships.split(ship_splitter)
            unless serialized_ship == ''
                ships.push fromSerialized(version, serialized_ship)

    ships

fromSerialized = (version, serialized) ->
    ship =
        pilot: null
        upgrades: []
        modifications: []
        title: null

    pilot_splitter = if version > 7 then 'X' else ':'
    upgrade_splitter = if version > 7 then 'W' else ','

    if (serialized.split(pilot_splitter)).length == 3
        [ pilot_id, upgrade_ids, conferredaddon_pairs ] = serialized.split(pilot_splitter)
    else
        [ pilot_id, upgrade_ids, version_4_compatibility_placeholder_title, version_4_compatibility_placeholder_mod, conferredaddon_pairs ] = serialized.split(pilot_splitter)
    try
        ship.pilot = cards.pilotsById[parseInt(pilot_id)]
    catch e
        return null

    for upgrade_id, i in upgrade_ids.split(upgrade_splitter)
        try
            upgrade_id = parseInt upgrade_id
            ship.upgrades.push(cards.upgradesById[upgrade_id]) if upgrade_id >= 0
        catch e
            ''

    ship
