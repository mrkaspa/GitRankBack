module Views exposing (..)

import Html exposing (Html, text, li)
import Charty.LineChart as LineChart
import Dict.Extra as DictExtra
import Dict exposing (Dict)
import Types exposing (..)
import List.Extra exposing (groupsOf)


viewCharts : LangGrouped -> List (Html Msg)
viewCharts langs =
    let
        renderChart langList =
            LineChart.view LineChart.defaults (sampleDataset langList)
    in
        langs
            |> groupsOf 5
            |> List.map renderChart


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
