module Types exposing (..)

import Http


type alias Lang =
    { id : Int
    , name : String
    , stars : Int
    , year : Int
    , month : Int
    }


type alias Model =
    List Lang


type alias LangGrouped =
    List ( String, List Lang )


type Msg
    = DataLoaded (Result Http.Error (List Lang))
