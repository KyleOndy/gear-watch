{-# LANGUAGE OverloadedStrings #-}

import Network.HTTP.Conduit (simpleHttp)
import Text.HTML.DOM (parseLBS)
import Text.Regex.TDFA
import Text.XML.Cursor


forumUrl :: String
forumUrl = "http://www.mountainproject.com/v/for-sale--wanted/103989416"

basePostUrl :: String
basePostUrl = "www.mountainproject.com"

-- data we are looking for
findNodes :: Cursor -> [Cursor]
findNodes = element "a" >=> attributeIs "target" "_top"

extractData = attribute "href"

cursorFor :: String -> IO Cursor
cursorFor u = do
  page <- simpleHttp u
  return $ fromDocument $ parseLBS page

cleanString :: String -> String
cleanString i =
  -- lol wut. Need to do some more learning
  reverse $ init $ init $ reverse $ init $ init i

--------------------------------------------------------------------------------

data SaleItem = SaleItem { url :: String
                         , description :: String
                         , postId :: String
                         } deriving (Show)

parseSaleItem :: Cursor -> SaleItem
parseSaleItem c =
  let u = basePostUrl ++ (cleanString $ show $ attribute "href" c)
      d = cleanString $ show $ content $ head $ child c
      pid = reverse $ takeWhile (\n -> n /= '/') $ reverse u
      in SaleItem {url = u, description = d, postId = pid}

--parseSaleItem:: Cursor -> (String, String)
--parseSaleItem c = ( attribute "href" c, show $ content $ head $ child c)

--------------------------------------------------------------------------------

main :: IO ()
main = do
  cursor <- cursorFor forumUrl
  mapM_ print $ map (parseSaleItem) $ cursor $// findNodes -- &| extractData
