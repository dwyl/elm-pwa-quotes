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
        [ main_ [ class "pa2" ]
            [ h1 [ class "tc" ] [ text <| (String.fromInt <| List.length model.quotes) ++ " Quotes" ]
            , ul [] (List.map (\q -> showQuote q) model.quotes)
            ]
        ]
    }


showQuote : Quote -> Html Msg
showQuote quote =
    li []
        [ text <| quote.text
        , span [ class "b" ] [ text quote.author ]
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
