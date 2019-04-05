# YASB permalink to XWS endpoint

Since raithos hosts [Yet Another X-Wing Squad Builder](https://raithos.github.io/xwing)
on GitHub pages, it can't arbitrarily respond to a request with
`application/json` (as far as I know).  So instead, here's an endpoint
that will take the permalink and spit out the XWS for it.

## install dependencies

    npm install

## Running the server

    npm start

## Updating the xwing submodule

This is necessary to keep the card list up to date with the builder.

    git submodule foreach git pull origin master


If using the heroku git plugin, to deploy:

    git push heroku master

