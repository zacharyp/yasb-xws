# YASB permalink to XWS endpoint

Since raithos hosts [Yet Another X-Wing Squad Builder](https://raithos.github.io/xwing)
on GitHub pages, it can't arbitrarily respond to a request with
`application/json` (as far as I know).  So instead, here's an endpoint
that will take the permalink and spit out the [XWS](https://github.com/elistevens/xws-spec) for it.

# yasb permalink to XWS

Take a [YASB](https://raithos.github.io/) permalink URL path, example `?f=Scum%20and%20Villainy&d=v6!h=200!147:124,111,,165,163:U.-1;103:,,,55,69,,,161:U.-1&sn=Guri%20Boba`, and use this to construct a GET request to:
```
http://yasb2-xws.herokuapp.com/?f=Scum%20and%20Villainy&d=v6!h=200!147:124,111,,165,163:U.-1;103:,,,55,69,,,161:U.-1&sn=Guri%20Boba&obs=
```
This will return an [XWS](https://github.com/elistevens/xws-spec) version of the x-wing squad, example:
```
{"faction":"scumandvillainy","pilots":[{"id":"guri","ship":"starviperclassattackplatform","points":93,"upgrades":{"talent":["lonewolf"],"sensor":["advancedsensors"],"modification":["shieldupgrade"],"title":["virago"]}},{"id":"bobafett","ship":"firesprayclasspatrolcraft","points":95,"upgrades":{"crew":["qira"],"device":["protonbombs"],"title":["slavei"]}}],"points":188,"vendor":{"yasb":{"builder":"(Yet Another) X-Wing Miniatures Squad Builder","builder_url":"https://raithos.github.io","link":"https://raithos.github.io/?f=Scum%20and%20Villainy&d=v6!h=200!147:124,111,,165,163:U.-1;103:,,,55,69,,,161:U.-1&sn=Guri%20Boba&obs="}},"version":"2.0.0","name":"Guri Boba"}
```

## Reverse XWS to YASB

In a reverse manner, there is also an endpoint to POST XWS document, and receive an YASB URL.  POST an XWS JSON document to `http://yasb2-xws.herokuapp.com/reverse` using `content-type` of `application/json`, and the code will scrape a version of the YASB site to produce a valid squad URL.

## install dependencies

    npm install

## Running the server

    npm start

## Updating the xwing submodule

This is necessary to keep the card list up to date with the builder.

    git submodule foreach git pull origin master


If using the heroku git plugin, to deploy:

    ### Needed for Puppeteer
    heroku buildpacks:set jontewks/puppeteer

    git push heroku master


## history
Originally a fork of https://github.com/geordanr/yasb-xws (thanks Geordan!), this project has deviated enough from the original to be its own thing
