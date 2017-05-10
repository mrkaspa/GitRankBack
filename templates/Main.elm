module Hello exposing (..)

import Html exposing (Html, div, text, ul, li)
import Http
import Json.Decode exposing (int, string, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Charty.LineChart as LineChart
import Dict.Extra as DictExtra
import Dict exposing (Dict)


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
    , year : Int
    , month : Int
    }


type alias Model =
    List Lang


type alias LangGrouped =
    List ( String, List Lang )


type Msg
    = DataLoaded (Result Http.Error (List Lang))


init : ( Model, Cmd Msg )
init =
    ( [], getData )


view : Model -> Html Msg
view model =
    let
        langs =
            mapModelToLangGrouped model

        topGrouped =
            List.take 5 langs
    in
        div []
            [ ul [] (List.map makeListItem topGrouped)
            , LineChart.view LineChart.defaults (sampleDataset topGrouped)
            ]


makeListItem : ( String, List Lang ) -> Html Msg
makeListItem ( name, stats ) =
    let
        stars =
            getFirstStars stats
    in
        li [] [ text (name ++ " - " ++ (toString stars)) ]


getFirstStars : List Lang -> Int
getFirstStars stats =
    stats
        |> List.head
        |> Maybe.map .stars
        |> Maybe.withDefault 0


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
        |> required "stats_year" int
        |> required "stats_month" int


sampleDataset : LangGrouped -> LineChart.Dataset
sampleDataset model =
    List.map mapLang model


mapModelToLangGrouped : Model -> LangGrouped
mapModelToLangGrouped model =
    model
        |> DictExtra.groupBy .name
        |> Dict.toList
        |> List.sortBy (\( _, stats ) -> getFirstStars stats)
        |> List.reverse


mapLang : ( String, List Lang ) -> LineChart.Series
mapLang ( name, stats ) =
    { label = name
    , data = List.map (\lang -> ( toFloat (lang.year + lang.month), toFloat (lang.stars) )) stats
    }
