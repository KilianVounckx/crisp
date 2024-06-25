This repo is archived, because with backpassing removed, the middleware API is
not possible anymore.

# Crisp

A proof of concept web framework built on top of
["basic-webserver"](https://github.com/roc-lang/basic-webserver).

The framework is based on how [gleam](https://gleam.run/)'s web framework
[wisp](https://hexdocs.pm/wisp/) works. Especially the way it handles middleware.
It uses gleam's use expressions, which translates very well to roc's backpassing.

## Proof of concept

Since this is just a proof of concept, I am not planning to turn this into a
production ready web framework. I do invite anyone to fork this repo and turn
it into something bigger!
