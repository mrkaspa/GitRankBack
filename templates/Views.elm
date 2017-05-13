module Views exposing (..)

import Html exposing (Html, text, li)
import Charty.LineChart as LineChart
import Dict.Extra as DictExtra
import Dict exposing (Dict)
import Types exposing (..)


viewCharts : LangGrouped -> List (Html Msg)
viewCharts langs =
    let
        renderChart langList =
            LineChart.view LineChart.defaults (sampleDataset langList)
    in
        langs
            |> groupEach 5
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


{-| Groups the elements of a list each times.

  groupEach 3 [3,4,5,7,8,9] == [[3,4,5],[7,8,9]]
  groupEach 3 [3,4,5,7,8] == [[3,4,5],[7,8]]
-}
groupEach : Int -> List a -> List (List a)
groupEach times list =
    let
        f a ( cont, elems, group, listIter ) =
            if cont == times || elems == 1 then
                ( 1, elems - 1, [], List.reverse (a :: group) :: listIter )
            else
                ( cont + 1, elems - 1, a :: group, listIter )

        ( _, _, _, grouped ) =
            List.foldl f ( 1, List.length list, [], [] ) list
    in
        List.reverse grouped
