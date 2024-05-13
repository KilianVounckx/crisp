module [
    middleware,
]

import ws.Http exposing [Request, Response]
import ws.Task exposing [Task]

import crisp.Crisp

middleware : Request, (Request -> Task Response _) -> Task Response _
middleware = \request0, handler ->
    {} <- Crisp.logRequest request0
    {} <- Crisp.rescueCrashes
    request1 <- Crisp.handleHead request0
    handler request1
