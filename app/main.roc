app [main] {
    ws: platform "https://github.com/roc-lang/basic-webserver/releases/download/0.5.0/Vq-iXfrRf-aHxhJpAh71uoVUlC-rsWvmjzTYOJKhu4M.tar.br",
}

import ws.Http exposing [Request, Response]
import ws.Task exposing [Task]

import Crisp
import Web

main : Request -> Task Response []
main = \request0 ->
    request1 <- Web.middleware request0
    when Crisp.pathSegments request1 is
        [] -> homePage request1
        ["comments"] -> comments request1
        ["comments", id] -> showComment request1 id
        _ -> Task.ok Crisp.notFound

homePage : Request -> Task Response []
homePage = \request ->
    {} <- Crisp.requireMethod request Get
    Task.ok {
        status: 200,
        body: Str.toUtf8 "Hello, World!",
        headers: [],
    }

comments : Request -> Task Response []
comments = \request ->
    when request.method is
        Get -> listComments
        Post -> createComment request
        _ -> Task.ok (Crisp.methodNotAllowed [Get, Post])

listComments : Task Response []
listComments =
    Task.ok {
        status: 200,
        body: Str.toUtf8 "Comments!",
        headers: [],
    }

createComment : Request -> Task Response []
createComment = \_request ->
    Task.ok {
        status: 200,
        body: Str.toUtf8 "Created!",
        headers: [],
    }

showComment : Request, Str -> Task Response []
showComment = \request, id ->
    {} <- Crisp.requireMethod request Get
    Task.ok {
        status: 200,
        body: Str.toUtf8 "Comment with id: $(id)",
        headers: [],
    }
