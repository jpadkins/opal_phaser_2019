# opal\_phaser\_2019

The [Phaser 3 Tutorial](http://phaser.io/tutorials/making-your-first-phaser-3-game/part1) implemented with [Opal](https://opalrb.com/). Specifically `Phaser 3.20.1` and `Opal 1.0`

## Running

To test locally, run

    bundle i && npm i && bundle exec rake build && npm start

and visit `http://localhost:8080`

or use your preferred local HTTP server

## TODO

Make more use of Opal's `Native::Helpers`, such as `alias_native` and `native_accessor`

Determine if there is a better way of handling the Phaser Scene functions, `preload`, `create`, `update`, etc.., besides instance variables and lambdas.

