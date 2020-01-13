module Main exposing (main)

import Array
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as JD
import Random
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
    , page : Page
    , quotes : List Quote
    , randomQuote : Int
    }


type alias Quote =
    { text : String
    , author : String
    }


type Page
    = AllQuotes
    | RandomQuote
    | Info


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key url AllQuotes [] 0, getQuotes )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotQuotes (Result Http.Error (List Quote))
    | GetRandomQuote Int


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
            let
                page =
                    case url.path of
                        "/all" ->
                            AllQuotes

                        "/info" ->
                            Info

                        _ ->
                            RandomQuote
            in
            ( { model | url = url, page = page }
            , Random.generate GetRandomQuote (Random.int 0 (List.length model.quotes))
            )

        GotQuotes result ->
            case result of
                Ok quotes ->
                    ( { model | quotes = quotes }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        GetRandomQuote i ->
            ( { model | randomQuote = i }, Cmd.none )



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
        , case model.page of
            AllQuotes ->
                showAllQuotesPage model

            RandomQuote ->
                showRandomQuote model

            Info ->
                showInfoPage
        ]
    }


showRandomQuote : Model -> Html Msg
showRandomQuote model =
    let
        quote =
            Array.get model.randomQuote (Array.fromList model.quotes)
    in
    main_ [ class "pa2" ]
        [ h1 [ class "tc" ] [ text "Random Quote" ]
        , div []
            [ case quote of
                Just q ->
                    showQuote q

                _ ->
                    text "No quotes available"
            , a [ class "tc center mw5 mw6-ns f6 link ph3 pv2 mb2 db white dwyl-bg-teal", href "/" ] [ text "Randomise" ]
            ]
        ]


showAllQuotesPage : Model -> Html Msg
showAllQuotesPage model =
    main_ [ class "pa2" ]
        [ h1 [ class "tc" ] [ text <| (String.fromInt <| List.length model.quotes) ++ " Quotes" ]
        , div [] (List.map (\q -> showQuote q) model.quotes)
        ]


showInfoPage : Html Msg
showInfoPage =
    main_ [ class "pa2" ]
        [ p [] [ text "See the following link if you which to add a quote" ]
        , a [ href "https://github.com/dwyl/quotes#contributing" ] [ text "https://github.com/dwyl/quotes#contributing" ]
        ]


showHeader : Html Msg
showHeader =
    header [ class "dwyl-bg-teal w-100 ph3 pv3 pv4-ns ph4-m ph5-l" ]
        [ nav [ class "f5 fw5 tracked" ]
            [ a [ class "link white dib mr5 b pointer", href "/" ] [ text "Get Inspired" ]
            , a [ class "link white dib mr5 b pointer", href "/all" ] [ text "All Quotes" ]
            , a [ class "link white dib mr5 b pointer", href "/info" ] [ text "Add Quotes" ]
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
