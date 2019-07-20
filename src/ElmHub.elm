port module ElmHub exposing (init, subscriptions, update, view)

import Github
import Html as UnstyledHtml
import Html.Attributes as UnstyledHtmlAttr
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttr
import Html.Styled.Events as HtmlEvents
import Html.Styled.Lazy as HtmlLazy
import Json.Decode as JsonDecode
import Table
import UI as UI



-- MODEL


type alias Model =
    { query : String
    , queryMinStars : Int
    , queryIn : String
    , queryUser : String
    , searchResult : SearchResult
    , tableState : Table.State
    }


type SearchResult
    = Success (List Github.Repo)
    | Loading
    | Failure String


type Msg
    = SetQuery String
    | SetQueryMinStars Int
    | SetQueryIn String
    | SetQueryUser String
    | Search
    | SearchSuccess (List Github.Repo)
    | SearchFail String
    | SetTableState Table.State


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , githubSearch <| buildQuery initialModel
    )


initialModel : Model
initialModel =
    { query = "tutorial"
    , queryMinStars = 0
    , queryIn = "name"
    , queryUser = ""
    , searchResult = Loading
    , tableState = Table.initialSort "Stars"
    }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetQuery userInput ->
            ( { model | query = userInput }, Cmd.none )

        SetQueryMinStars int ->
            ( { model | queryMinStars = int }, Cmd.none )

        SetQueryIn string ->
            ( { model | queryIn = string }, Cmd.none )

        SetQueryUser string ->
            ( { model | queryUser = string }, Cmd.none )

        Search ->
            ( { model | searchResult = Loading }
            , githubSearch <| buildQuery model
            )

        SearchSuccess searchResults ->
            ( { model | searchResult = Success searchResults }, Cmd.none )

        SearchFail err ->
            ( { model | searchResult = Failure err }, Cmd.none )

        SetTableState state ->
            ( { model | tableState = state }, Cmd.none )



-- SUBSCRIPTION


port githubSearch : Query -> Cmd msg


type alias Query =
    { query : String
    , queryMinStars : Int
    , queryIn : String
    , queryUser : String
    }


buildQuery : Model -> Query
buildQuery model =
    { query = model.query
    , queryMinStars = model.queryMinStars
    , queryIn = model.queryIn
    , queryUser = model.queryUser
    }


port githubResponse : (JsonDecode.Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    githubResponse decodeResponse


decodeResponse : JsonDecode.Value -> Msg
decodeResponse json =
    case JsonDecode.decodeValue Github.responseDecoder json of
        Result.Ok listRepo ->
            SearchSuccess listRepo

        Result.Err err ->
            SearchFail <| JsonDecode.errorToString err



-- VIEW


view : Model -> UnstyledHtml.Html Msg
view model =
    Html.toUnstyled <|
        UI.appContainer
            [ elmHubHeader
            , HtmlLazy.lazy viewSearchOptions model
            , viewSearchQuery model
            , viewSearchAction
            , viewSearchResult model
            ]


optionMsgToMsg : OptionsMsg -> Msg
optionMsgToMsg optionsMsg =
    case optionsMsg of
        SetMinStars string ->
            SetQueryMinStars <| Maybe.withDefault 0 (String.toInt string)

        SetSearchIn string ->
            SetQueryIn string

        SetUserFilter string ->
            SetQueryUser string


viewSearchAction : Html.Html Msg
viewSearchAction =
    UI.searchButton Search [ Html.text "Search" ]


type OptionsMsg
    = SetMinStars String
    | SetSearchIn String
    | SetUserFilter String


viewSearchOptions : Model -> Html.Html Msg
viewSearchOptions model =
    Html.map optionMsgToMsg <|
        UI.searchOptions
            [ UI.searchOption
                [ UI.topLabel [ Html.text "Search in" ]
                , UI.select
                    SetSearchIn
                    model.queryIn
                    [ Html.option [ HtmlAttr.value "name" ] [ Html.text "Name" ]
                    , Html.option [ HtmlAttr.value "description" ] [ Html.text "Description" ]
                    , Html.option [ HtmlAttr.value "name,description" ] [ Html.text "Name and Description" ]
                    ]
                ]
            , UI.searchOption
                [ UI.topLabel [ Html.text "Owned by" ]
                , Html.input
                    [ HtmlAttr.type_ "text"
                    , HtmlAttr.placeholder "Enter a username"
                    , HtmlAttr.value model.queryUser
                    , HtmlEvents.onInput SetUserFilter
                    ]
                    []
                ]
            , UI.searchOption
                [ UI.topLabel [ Html.text "Minimum Stars" ]
                , Html.input
                    [ HtmlAttr.type_ "number"
                    , onBlurWithTargetValue SetMinStars
                    , HtmlAttr.value (String.fromInt model.queryMinStars)
                    ]
                    []
                ]
            ]


viewSearchQuery : Model -> Html.Html Msg
viewSearchQuery model =
    UI.searchQuery SetQuery Search model.query


onBlurWithTargetValue : (String -> msg) -> Html.Attribute msg
onBlurWithTargetValue toMsg =
    HtmlEvents.on "blur" (JsonDecode.map toMsg HtmlEvents.targetValue)


elmHubHeader : Html.Html Msg
elmHubHeader =
    UI.header
        [ UI.title [ Html.text "ElmHub" ]
        , UI.tagLine [ Html.text "Like GitHub, but for Elm things." ]
        ]


viewSearchResult : Model -> Html.Html Msg
viewSearchResult model =
    let
        starsColumn : Table.Column Github.Repo msg
        starsColumn =
            Table.customColumn
                { name = "Stars"
                , viewData = .stars >> String.fromInt
                , sorter = Table.decreasingOrIncreasingBy .stars
                }

        githubUrlColumn : Table.Column Github.Repo msg
        githubUrlColumn =
            Table.veryCustomColumn
                { name = "Url"
                , viewData = .name >> viewGithubUrl
                , sorter = Table.unsortable
                }

        idColumn : Table.Column Github.Repo msg
        idColumn =
            Table.customColumn
                { name = "Id"
                , viewData = .id >> String.fromInt
                , sorter = Table.unsortable
                }

        nameColumn : Table.Column Github.Repo msg
        nameColumn =
            Table.customColumn
                { name = "Name"
                , viewData = .name
                , sorter = Table.unsortable
                }

        defaultCustomizations =
            Table.defaultCustomizations

        tableConfig : Table.Config Github.Repo Msg
        tableConfig =
            Table.customConfig
                { toId = String.fromInt << .id
                , toMsg = SetTableState
                , columns =
                    [ idColumn
                    , nameColumn
                    , starsColumn
                    , githubUrlColumn
                    ]
                , customizations =
                    { defaultCustomizations
                        | thead = viewTHead
                        , rowAttrs = toRowAttrs
                    }
                }
    in
    case model.searchResult of
        Success repos ->
            viewRepos tableConfig model.tableState repos

        Failure err ->
            UI.errorContainer [ Html.text ("Failed to fetch: " ++ err) ]

        Loading ->
            Html.text "Loading..."


toRowAttrs _ =
    [ UnstyledHtmlAttr.style "font-size" "20px"
    , UnstyledHtmlAttr.style "padding-right" "20px"
    ]


viewTHead headers =
    Table.HtmlDetails [] (List.map simpleTheadHelp headers)


darkGrey : String -> Html.Html msg
darkGrey symbol =
    Html.span [ HtmlAttr.style "color" "#555" ] [ Html.text (" " ++ symbol) ]


lightGrey : String -> Html.Html msg
lightGrey symbol =
    Html.span [ HtmlAttr.style "color" "#ccc" ] [ Html.text (" " ++ symbol) ]


simpleTheadHelp : ( String, Table.Status, UnstyledHtml.Attribute msg ) -> UnstyledHtml.Html msg
simpleTheadHelp ( name, status, onClick_ ) =
    let
        content =
            case status of
                Table.Unsortable ->
                    [ Html.text name ]

                Table.Sortable selected ->
                    [ Html.text name
                    , if selected then
                        darkGrey "↓"

                      else
                        lightGrey "↓"
                    ]

                Table.Reversible Nothing ->
                    [ Html.text name
                    , lightGrey "↕"
                    ]

                Table.Reversible (Just isReversed) ->
                    [ Html.text name
                    , darkGrey
                        (if isReversed then
                            "↑"

                         else
                            "↓"
                        )
                    ]
    in
    Html.toUnstyled <| UI.thead (HtmlAttr.fromUnstyled onClick_) content


viewGithubUrl : String -> Table.HtmlDetails msg
viewGithubUrl name =
    let
        url =
            "https://github.com/" ++ name
    in
    Table.HtmlDetails []
        [ Html.toUnstyled <| UI.a url [ Html.text url ] ]


viewRepos : Table.Config Github.Repo msg -> Table.State -> List Github.Repo -> Html.Html msg
viewRepos tableConfig tableState repos =
    Html.fromUnstyled <| Table.view tableConfig tableState repos
