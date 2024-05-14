module [
    handleHead,
    logRequest,
    requireForm,
    requireMethod,
    requireStringBody,
    rescueCrashes,
    badRequest,
    methodNotAllowed,
    notFound,
    unsupportedMediaType,
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

FormData : Dict Str Str

requireForm : Request, (FormData -> Task Response _) -> Task Response _
requireForm = \request, handler ->
    when
        request.headers
        |> List.findFirst \{ name } -> name == "content-type"
        |> Result.try \{ value } -> Str.fromUtf8 value
    is
        Ok "application/x-www-form-urlencoded" ->
            requireUrlencodedForm request handler

        Ok header if Str.startsWith header "application/x-www-form-urlencoded;" ->
            requireUrlencodedForm request handler

        Ok header if Str.startsWith header "multipart/form-data; boundary=" ->
            when Str.splitFirst header "multipart/form-data; boundary=" is
                Err err -> crash "should be unreachable $(Inspect.toStr err)"
                Ok { after: boundary } ->
                    requireMultipartForm request boundary handler

        Ok "multipart/form-data" ->
            Task.ok badRequest

        _ ->
            Task.ok (unsupportedMediaType ["application/x-www-form-urlencoded", "multipart/form-data"])

requireUrlencodedForm : Request, (FormData -> Task Response _) -> Task Response _
requireUrlencodedForm = \request, handler ->
    body <- requireStringBody request
    body
    |> \s -> Str.concat "?" s
    |> Url.fromStr
    |> Url.queryParams
    |> handler

requireMultipartForm : Request, Str, (FormData -> Task Response _) -> Task Response _

requireMethod : Request, Http.Method, ({} -> Task Response _) -> Task Response _
requireMethod = \request, method, handler ->
    if request.method == method then
        handler {}
    else
        Task.ok (methodNotAllowed [method])

requireStringBody : Request, (Str -> Task Response _) -> Task Response _
requireStringBody = \request, handler ->
    when Str.fromUtf8 request.body is
        Ok str -> handler str
        Err _ -> Task.ok badRequest

rescueCrashes : ({} -> Task Response _) -> Task Response []
rescueCrashes = \handler ->
    Task.attempt (handler {}) \result ->
        when result is
            Ok response -> Task.ok response
            Err _ -> Task.ok { status: 500, body: [], headers: [] }

# Responses

badRequest : Response
badRequest = { status: 400, body: [], headers: [] }

methodNotAllowed : List Http.Method -> Response
methodNotAllowed = \methods ->
    allowed =
        methods
        |> List.map Http.methodToStr
        |> Str.joinWith ", "
    { status: 405, body: [], headers: [{ name: "allow", value: Str.toUtf8 allowed }] }

notFound : Response
notFound = { status: 404, body: [], headers: [] }

unsupportedMediaType : List Str -> Response
unsupportedMediaType = \types ->
    acceptable = Str.joinWith types ", "
    { status: 415, body: [], headers: [{ name: "accept", value: Str.toUtf8 acceptable }] }

# Utilities

pathSegments : Request -> List Str
pathSegments = \request ->
    request.url
    |> Url.fromStr
    |> Url.path
    |> Str.split "/"
    |> List.dropIf Str.isEmpty
