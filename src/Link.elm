module Link exposing (fetchLink)

import Api.Object exposing (Link(..))
import Api.Object.Link as Link
import Api.Query as Query
import Api.Scalar as Scalar
import Browser
import Element exposing (Element, el, text)
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData(..), WebData)


endpoint : String
endpoint =
    "http://localhost:4000/graphql"


type alias BaggyLink =
    { id : Scalar.Id
    , hash : Maybe String
    , url : Maybe String
    }


type alias LinkResponse =
    Maybe BaggyLink


getLinkQuery : SelectionSet LinkResponse RootQuery
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
        , view = view
        }



-- MODEL


type alias Model =
    { link : WebData BaggyLink }



-- UPDATE


type Msg
    = GotResponse ( WebData BaggyLink )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponse response ->
            ( { model | link = response } , Cmd.none )


-- INIT

type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { link = Loading } , fetchLink )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Bagheera"
    , body = [ Element.layout [] (viewLink model) ]
    }


viewLink : Model -> Element msg
viewLink model =
    case model.link of
        NotAsked ->
            el [] (text "NotAsked")

        Loading ->
            el []  (text "Loading...")

        Failure err ->
            el [] (text "Failed... [pattern match error.message & error.details here]")

        Success link ->
            el [] (text (Maybe.withDefault "WTF" <| link.url))

