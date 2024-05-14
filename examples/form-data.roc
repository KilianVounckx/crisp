app [main] {
    ws: platform "https://github.com/roc-lang/basic-webserver/releases/download/0.5.0/Vq-iXfrRf-aHxhJpAh71uoVUlC-rsWvmjzTYOJKhu4M.tar.br",
    crisp: "../package/main.roc",
}

import ws.Http exposing [Request, Response]
import ws.Task exposing [Task]

import crisp.Crisp

import Web

main : Request -> Task Response []
main = \request0 ->
    request1 <- Web.middleware request0
    when request1.method is
        Get -> showForm
        Post -> handleFormSubmission request1
        _ -> Task.ok (Crisp.methodNotAllowed [Get, Post])

showForm : Task Response []
showForm =
    html =
        """
        <form method='post'>
            <label>Title:
                <input type='text' name='title'>
            </label>
            <label>Name:
                <input type='text' name='name'>
            </label>
            <input type='submit' value='Submit'>
        </form>
        """
    Task.ok { status: 200, body: Str.toUtf8 html, headers: [] }

handleFormSubmission : Request -> Task Response []
handleFormSubmission = \request ->
    formdata <- Crisp.requireForm request
    result =
        title <- Result.try (Dict.get formdata "title")
        name <- Result.map (Dict.get formdata "name")
        "Hi, $(title) $(name)!"
    when result is
        Ok content ->
            Task.ok {
                status: 200,
                body: Str.toUtf8 content,
                headers: [],
            }

        Err _ -> Task.ok Crisp.badRequest
