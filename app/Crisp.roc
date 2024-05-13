module [
    handleHead,
    logRequest,
    requireMethod,
    rescueCrashes,
    methodNotAllowed,
    notFound,
    pathSegments,
]

import ws.Http exposing [Request, Response]
import ws.Stdout
import ws.Task exposing [Task]
import ws.Url

# Handlers

handleHead : Request, (Request -> Task Response _) -> Task Response _
handleHead = \request, handler ->
    when request.method is
        Head ->
            newHeaders = List.prepend request.headers {
                name: "x-original-method",
                value: Str.toUtf8 "HEAD",
            }
            newRequest = { request & method: Get, headers: newHeaders }
            response <- Task.await (handler newRequest)
            Task.ok { response & body: [] }

        _ -> handler request

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

requireMethod : Request, Http.Method, ({} -> Task Response _) -> Task Response _
requireMethod = \request, method, handler ->
    if request.method == method then
        handler {}
    else
        Task.ok (methodNotAllowed [method])

rescueCrashes : ({} -> Task Response _) -> Task Response []
rescueCrashes = \handler ->
    Task.attempt (handler {}) \result ->
        when result is
            Ok response -> Task.ok response
            Err _ -> Task.ok { status: 500, body: [], headers: [] }

# Responses

methodNotAllowed : List Http.Method -> Response
methodNotAllowed = \methods ->
    allowed =
        methods
        |> List.map Http.methodToStr
        |> Str.joinWith ", "
    { status: 405, body: [], headers: [{ name: "allow", value: Str.toUtf8 allowed }] }

notFound : Response
notFound = { status: 404, body: [], headers: [] }

# Utilities

pathSegments : Request -> List Str
pathSegments = \request ->
    request.url
    |> Url.fromStr
    |> Url.path
    |> Str.split "/"
    |> List.dropIf Str.isEmpty
