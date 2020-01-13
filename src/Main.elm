module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as JD
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , quotes : List Quote
    }


type alias Quote =
    { text : String
    , author : String
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key url [], getQuotes )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotQuotes (Result Http.Error (List Quote))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        GotQuotes result ->
            case result of
                Ok quotes ->
                    ( { model | quotes = quotes }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "DWYL Quotes"
    , body =
        [ showHeader
        , main_ [ class "pa2" ]
            [ h1 [ class "tc" ] [ text <| (String.fromInt <| List.length model.quotes) ++ " Quotes" ]
            , div [] (List.map (\q -> showQuote q) model.quotes)
            ]
        ]
    }


showHeader : Html Msg
showHeader =
    header [ class "dwyl-bg-teal w-100 ph3 pv3 pv4-ns ph4-m ph5-l" ]
        [ nav [ class "f5 fw5 tracked" ]
            [ a [ class "link white dib mr5 b pointer" ] [ text "Get Inspired" ]
            , a [ class "link white dib mr5 b pointer" ] [ text "All Quotes" ]
            ]
        ]


showQuote : Quote -> Html Msg
showQuote quote =
    article [ class "center mw5 mw6-ns br3 hidden ba b--black-10 mv4" ]
        [ h1 [ class "f4 bg-near-white br3 br--top black-60 mv0 pv2 ph3" ] [ text quote.author ]
        , div [ class "pa3 bt b--black-10" ]
            [ p [ class "f6 f5-ns lh-copy measure" ] [ text quote.text ]
            ]
        ]


getQuotes : Cmd Msg
getQuotes =
    Http.get
        { url = "https://raw.githubusercontent.com/dwyl/quotes/master/quotes.json"
        , expect = Http.expectJson GotQuotes quotesDecoder
        }


quotesDecoder : JD.Decoder (List Quote)
quotesDecoder =
    JD.list quoteDecoder


quoteDecoder : JD.Decoder Quote
quoteDecoder =
    JD.map2 Quote
        (JD.field "text" JD.string)
        (JD.field "author" JD.string)
