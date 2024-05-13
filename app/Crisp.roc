module [
    logRequest,
    rescueCrashes,
]

import ws.Http exposing [Request, Response]
import ws.Stdout
import ws.Task exposing [Task]

logRequest : Request, ({} -> Task Response _) -> Task Response _
logRequest = \request, handler ->
    response <- Task.await (handler {})
    {} <-
        [
            Num.toStr response.status,
            Http.methodToStr request.method,
            request.url,
        ]
        |> Str.joinWith " "
        |> Stdout.line
        |> Task.map
    response

rescueCrashes : ({} -> Task Response _) -> Task Response []
rescueCrashes = \handler ->
    Task.attempt (handler {}) \result ->
        when result is
            Ok response -> Task.ok response
            Err _ -> Task.ok { status: 500, body: [], headers: [] }
