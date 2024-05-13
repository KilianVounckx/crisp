app [main] {
    ws: platform "https://github.com/roc-lang/basic-webserver/releases/download/0.5.0/Vq-iXfrRf-aHxhJpAh71uoVUlC-rsWvmjzTYOJKhu4M.tar.br",
    crisp: "../package/main.roc",
}

import ws.Http exposing [Request, Response]
import ws.Task exposing [Task]

import Web

main : Request -> Task Response []
main = \request ->
    {} <- Web.middleware request
    Task.ok {
        status: 200,
        body: Str.toUtf8 "Hello, World!",
        headers: [],
    }
