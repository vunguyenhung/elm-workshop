module Github exposing (Repo, responseDecoder)

import Json.Decode as JsonDecode


type alias Repo =
    { id : Int, name : String, stars : Int }


responseDecoder : JsonDecode.Decoder (List Repo)
responseDecoder =
    JsonDecode.at [ "items" ] <|
        JsonDecode.list <|
            JsonDecode.map3 Repo
                (JsonDecode.field "id" JsonDecode.int)
                (JsonDecode.field "full_name" JsonDecode.string)
                (JsonDecode.field "stargazers_count" JsonDecode.int)
