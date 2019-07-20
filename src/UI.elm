module UI exposing (a, appContainer, errorContainer, header, searchButton, searchOption, searchOptions, searchQuery, select, tagLine, thead, title, topLabel)

import Css as Css
import Css.Global as CssGlobal
import Html.Styled as HtmlStyled
import Html.Styled.Attributes as HtmlStyledAttr
import Html.Styled.Events as HtmlStyledEvents
import Json.Decode as JsonDecode


appContainer : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
appContainer =
    HtmlStyled.div
        [ HtmlStyledAttr.css
            [ Css.width <| Css.px 960
            , Css.margin2 Css.zero Css.auto
            , Css.padding <| Css.px 30
            , Css.fontFamilies [ "Helvetica", "Arial", "serif" ]
            , Css.backgroundColor (Css.rgb 250 250 250)
            ]
        ]


header : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
header =
    HtmlStyled.header
        [ HtmlStyledAttr.css
            [ Css.position Css.relative
            , Css.padding2 (Css.px 6) (Css.px 12)
            , Css.height (Css.px 36)
            , Css.backgroundColor (Css.rgb 96 181 204)
            ]
        ]


title : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
title =
    HtmlStyled.h1
        [ HtmlStyledAttr.css
            [ Css.color (Css.hex "ffffff")
            , Css.margin Css.zero
            , Css.fontWeight Css.normal
            ]
        ]


tagLine : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
tagLine =
    HtmlStyled.span
        [ HtmlStyledAttr.css
            [ Css.color (Css.hex "eeeeee")
            , Css.position Css.absolute
            , Css.right (Css.px 16)
            , Css.top (Css.px 12)
            , Css.fontSize (Css.px 24)
            , Css.fontStyle Css.italic
            ]
        ]


searchOptions : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
searchOptions =
    HtmlStyled.div
        [ HtmlStyledAttr.css
            [ Css.position Css.relative
            , Css.property "float" "right"
            , Css.width (Css.pct 58)
            , Css.boxSizing Css.borderBox
            , Css.paddingTop (Css.px 20)
            ]
        ]


searchOption : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
searchOption =
    HtmlStyled.div
        [ HtmlStyledAttr.css
            [ Css.display Css.block
            , Css.property "float" "left"
            , Css.width (Css.pct 30)
            , Css.marginLeft (Css.px 16)
            , Css.boxSizing Css.borderBox
            , CssGlobal.descendants
                [ CssGlobal.selector "input[type=\"text\"]"
                    [ Css.padding (Css.px 5)
                    , Css.boxSizing Css.borderBox
                    , Css.width (Css.pct 90)
                    ]
                ]
            ]
        ]


select onChangeMsg value =
    HtmlStyled.select [ onChange onChangeMsg, HtmlStyledAttr.value value ]


onChange : (String -> msg) -> HtmlStyled.Attribute msg
onChange toMsg =
    HtmlStyledEvents.on "change" (JsonDecode.map toMsg HtmlStyledEvents.targetValue)


topLabel : List (HtmlStyled.Html msg) -> HtmlStyled.Html msg
topLabel =
    HtmlStyled.label
        [ HtmlStyledAttr.css
            [ Css.display Css.block
            , Css.color (Css.hex "555555")
            ]
        ]


onEnter : msg -> HtmlStyled.Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                JsonDecode.succeed msg

            else
                JsonDecode.fail "not ENTER"
    in
    HtmlStyledEvents.on "keydown" (JsonDecode.andThen isEnter HtmlStyledEvents.keyCode)


searchQuery onInputMsg onEnterMsg value =
    HtmlStyled.input
        [ HtmlStyledAttr.css
            [ Css.padding (Css.px 8)
            , Css.fontSize (Css.px 24)
            , Css.marginBottom (Css.px 18)
            , Css.marginTop (Css.px 36)
            ]
        , HtmlStyledEvents.onInput onInputMsg
        , onEnter onEnterMsg
        , HtmlStyledAttr.value value
        ]
        []


searchButton onClickMsg =
    HtmlStyled.button
        [ HtmlStyledAttr.css
            [ Css.padding2 (Css.px 8) (Css.px 20)
            , Css.fontSize (Css.px 24)
            , Css.color (Css.hex "ffffff")
            , Css.border3 (Css.px 1) Css.solid (Css.hex "cccccc")
            , Css.backgroundColor (Css.rgb 96 181 204)
            , Css.marginLeft (Css.px 12)
            , Css.hover
                [ Css.color (Css.rgb 96 181 204)
                , Css.backgroundColor (Css.hex "ffffff")
                ]
            ]
        , HtmlStyledEvents.onClick onClickMsg
        ]


errorContainer =
    HtmlStyled.div
        [ HtmlStyledAttr.css
            [ Css.backgroundColor (Css.hex "FF9632")
            , Css.padding (Css.px 20)
            , Css.boxSizing Css.borderBox
            , Css.overflowX Css.auto
            , Css.fontFamily Css.monospace
            , Css.fontSize (Css.px 18)
            ]
        ]


a href =
    HtmlStyled.a
        [ HtmlStyledAttr.css
            [ Css.color (Css.rgb 96 181 204)
            , Css.textDecoration Css.none
            , Css.hover
                [ Css.textDecoration Css.underline ]
            ]
        , HtmlStyledAttr.href href
        , openOnNewTab
        ]


openOnNewTab =
    HtmlStyledAttr.target "_blank"


thead onClickAttr =
    HtmlStyled.th
        [ HtmlStyledAttr.css
            [ Css.textAlign Css.left
            , Css.cursor Css.pointer
            , Css.hover [ Css.color (Css.rgb 96 181 204) ]
            , Css.fontSize (Css.px 18)
            ]
        , onClickAttr
        ]
