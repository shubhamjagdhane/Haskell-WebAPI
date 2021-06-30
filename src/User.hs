{-# OPTIONS_GHC -fno-warn-unused-binds #-}
{-# LANGUAGE MultiParamTypeClasses, TypeFamilies, OverloadedStrings, DataKinds, TypeOperators, TypeSynonymInstances, FlexibleInstances, DeriveGeneric #-}

module User where

import WebApi
  
import WebApi.Server
  
   
import GHC.Generics ( Generic )
import Data.Text (Text)
import Data.Aeson

import Network.Wai.Handler.Warp (run)
import qualified Network.Wai as Wai


data MyApiService
 
type User   = Static "user"
type UserId = "user":/Int

instance WebApi MyApiService where
  -- Route <Method>  <Route Name>
   type Apis MyApiService = 
     '[ 
        Route '[POST] User
      , Route '[GET]  UserId
      ]

-- Our user type
data UserData = 
  UserData { 
      age     :: Int
    , address :: Text
    , name    :: Text
  } deriving (Show, Eq, Generic)

data UserToken = 
  UserToken { 
    userId :: Text
  , token :: Text
  } deriving (Show, Eq, Generic)                             

instance ApiContract MyApiService POST User where
  -- type FormParam POST User = UserData
  type RequestBody POST User = '[UserData]-- request param  
  type ApiOut    POST User = UserToken -- response param

instance ApiContract MyApiService GET UserId where
  type ApiOut GET UserId = UserData -- response param

instance FromJSON UserData
instance ToJSON   UserData

instance FromJSON UserToken
instance ToJSON   UserToken
-- instance FromParam 'FormParam UserData

-- web server implementation

data MyApiServiceImpl = MyApiServiceImpl

instance WebApiServer MyApiServiceImpl where
  type HandlerM MyApiServiceImpl = IO
  type ApiInterface MyApiServiceImpl = MyApiService

instance ApiHandler MyApiServiceImpl POST User where
  handler _ req = do
    let _userInfo = requestBody req
    respond (UserToken "Foo" "Bar")

instance ApiHandler MyApiServiceImpl GET UserId where
 handler _ req = do 
  let _userid =  req
  respond (UserData 24 "Pune" "Shubham")

myApiApp :: Wai.Application
myApiApp = serverApp serverSettings MyApiServiceImpl

startServer :: IO ()
startServer = run 8000 myApiApp      

{-
GET METHOD:
curl http://localhost:8000/user/1

POST METHOD
curl -H "Content-Type: application/x-www-form-urlencoded" -d 'age=24&address=Pune&name=Shubham' http://localhost:8000/user

POST METHOD => JSON input
curl -H "Content-Type: application/json" -d '{"age":24, "address": "Pune", "name":"Shubham"}' http://localhost:8000/user

-}