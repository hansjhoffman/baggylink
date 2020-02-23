module Main exposing (main)

import Api.Object exposing (Link(..))
import Api.Object.Link as Link
import Api.Query as Query
import Api.Scalar as Scalar
import Browser
import Element exposing (Element, el, text)
import Graphql.Document as Document
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)


endpoint : String
endpoint =
    "http://localhost:4000/graphql"


type alias BaggyLink =
    { id : Scalar.Id
    , hash : Maybe String
    , url : Maybe String
    }


type alias Response =
    Maybe BaggyLink


getLinkQuery : SelectionSet Response RootQuery
getLinkQuery =
    Query.link { id = Scalar.Id "TGluazo2" } linkSelection


linkSelection : SelectionSet BaggyLink Link
linkSelection =
    SelectionSet.map3 BaggyLink
        Link.id
        Link.hash
        Link.url


fetchLink : Cmd Msg
fetchLink =
    getLinkQuery
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view (Document.serializeQuery getLinkQuery)
        }



-- MODEL


type alias Model =
    RemoteData (Graphql.Http.Error Response) Response



-- UPDATE


type Msg
    = GotResponse Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponse response ->
            ( response, Cmd.none )


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( RemoteData.Loading, fetchLink )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : String -> Model -> Browser.Document Msg
view queryString model =
    { title = "Bagheera"
    , body = [ Element.layout [] viewGreeting ]
    }


viewGreeting : Element msg
viewGreeting =
    el [] (text "hello hansy")
