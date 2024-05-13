module [
    middleware,
]

import ws.Http exposing [Request, Response]
import ws.Task exposing [Task]

import Crisp

middleware : Request, (Request -> Task Response _) -> Task Response _
middleware = \request, handler ->
    {} <- Crisp.logRequest request
    {} <- Crisp.rescueCrashes
    handler request
