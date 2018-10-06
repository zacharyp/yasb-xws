cards = require('./xwing/coffeescripts/cards-common').basicCardData()
permalink = require './permalink'

XWS_VERSION = '2.0.0'

fromXWSFaction =
    'rebelalliance': 'Rebel Alliance'
    'rebels': 'Rebel Alliance'
    'rebel': 'Rebel Alliance'
    'galacticempire': 'Galactic Empire'
    'imperial': 'Galactic Empire'
    'scumandvillainy': 'Scum and Villainy'
    'firstorder': 'First Order'
    'resistance': 'Resistance'

toXWSFaction =
    'Rebel Alliance': 'rebelalliance'
    'Galactic Empire': 'galacticempire'
    'Scum and Villainy': 'scumandvillainy'
    'First Order': 'firstorder'
    'Resistance': 'resistance'

toXWSUpgrade =
    'Modification': 'mod'

fromXWSUpgrade =
    'amd': 'Astromech'
    'astromechdroid': 'Astromech'
    'ept': 'Talent'
    'elitepilottalent': 'Talent'
    'system': 'Sensor'
    'mod': 'Modification'

exportObj = exports ? this

exportObj.serializedToXWS = ({faction, serialized, name, obstacles}) ->
    xws =
        faction: toXWSFaction[faction]
        pilots: []
        vendor:
            yasb:
                builder: '(Yet Another) X-Wing Miniatures Squad Builder'
                builder_url: 'https://raithos.github.io'
                link: 'https://raithos.github.io'
        version: XWS_VERSION

    if name?.length and ['Unnamed Squadron', 'New Squadron'].indexOf(name) == -1
      xws.name = name

    if obstacles?
      obs = obstacles.split(',')
      if obs.length == 3
        xws.obstacles = obs

    for ship in permalink.serializedToShips faction, serialized
        continue unless ship?.pilot?
        try
            shipdata = cards.ships[ship.pilot.ship]
        catch e
            console.error "Unknown ship: #{e}"
            continue
        
        try
            pilot =
                id: ship.pilot.xws ? ship.pilot.canonical_name ? ship.pilot.name.canonicalize()
                ship: shipdata.xws ? shipdata.canonical_name ? shipdata.name.canonicalize()
        catch e
            console.error "Cannot set pilot and ship: #{e}"
            continue

        upgrade_obj = {}

        for upgrade in ship.upgrades
            try
                slot = toXWSUpgrade[upgrade.slot] ? upgrade.slot.canonicalize()
            catch e
                console.error "Cannot add determine slot: #{e}"
                console.dir upgrade
                continue

            try
                (upgrade_obj[slot] ?= []).push(upgrade.xws ? upgrade.canonical_name ? upgrade.name.canonicalize())
            catch e
                console.error "Cannot add upgrade: #{e}"
                continue

        for modification in ship.modifications
            try
                (upgrade_obj[toXWSUpgrade['Modification']] ?= []).push(modification.xws ? modification.canonical_name ? modification.name.canonicalize())
            catch e
                console.error "Cannot add modification: #{e}"
                continue

        if ship.title?
            try
                (upgrade_obj.title ?= []).push(ship.title.xws ? ship.title.canonical_name ? ship.title.name.canonicalize())
            catch e
                console.error "Cannot add title: #{e}"
                continue

        if Object.keys(upgrade_obj).length > 0
            pilot.upgrades = upgrade_obj

        xws.pilots.push pilot

    xws
