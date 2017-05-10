module Hello exposing (..)

import Html exposing (..)
import Html exposing (text, ul, li)
import Http
import Json.Decode exposing (int, string, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }


type alias Lang =
    { id : Int
    , name : String
    , stars : Int
    }


type alias Model =
    List Lang


type Msg
    = DataLoaded (Result Http.Error (List Lang))


init : ( Model, Cmd Msg )
init =
    ( [], getData )


view : Model -> Html Msg
view model =
    ul [] (List.map (\a -> li [] [ text (a.name ++ " - " ++ (toString a.stars)) ]) model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataLoaded (Ok newData) ->
            ( newData, Cmd.none )

        _ ->
            ( model, Cmd.none )


getData : Cmd Msg
getData =
    let
        url =
            "/load_info"
    in
        Http.send DataLoaded (Http.get url langsDecoder)


langsDecoder : Decoder (List Lang)
langsDecoder =
    list langDecoder


langDecoder : Decoder Lang
langDecoder =
    decode Lang
        |> required "langs_id" int
        |> required "langs_name" string
        |> required "stats_stars" int
