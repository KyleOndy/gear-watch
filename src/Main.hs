{-# LANGUAGE OverloadedStrings #-}

import Network.HTTP.Conduit (simpleHttp)
import Text.HTML.DOM (parseLBS)
import Text.Regex.TDFA
import Text.XML.Cursor
import Data.Map (toList)
import Data.List
import Data.List.Split


siteUrl :: String
siteUrl = "http://www.mountainproject.com"

forSaleForum :: String
forSaleForum = siteUrl ++ "/v/for-sale--wanted/103989416"

fullUrl :: String
fullUrl = "www.mountainproject.com/v/for-sale--wanted/103989416"

-- data we are looking for
findNodes :: Cursor -> [Cursor]
findNodes = element "a" >=> attributeIs "target" "_top"

extractData = attribute "href"

cursorFor :: String -> IO Cursor
cursorFor u = do
  page <- simpleHttp u
  return $ fromDocument $ parseLBS page

-- The strings are coming with strange chracters. Maybe I need a different
-- encoding?
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
  let u = siteUrl ++ (cleanString $ show $ attribute "href" c)
      d = cleanString $ show $ content $ head $ child c
      --pid = reverse $ takeWhile (\n -> n /= '/') $ reverse u
      pid = reverse $ takeWhile (/= '/') $ reverse u
      in SaleItem {url = u, description = d, postId = pid}

--parseSaleItem:: Cursor -> (String, String)
--parseSaleItem c = ( attribute "href" c, show $ content $ head $ child c)

--------------------------------------------------------------------------------

getFrontPageSales :: Cursor -> [SaleItem]
getFrontPageSales c =
  map parseSaleItem $ c $// findNodes -- &| extractData

checkedPosts :: String
checkedPosts = ".checked.txt"

frontPageSaleIds :: [SaleItem] -> [String]
frontPageSaleIds items =
  map postId $ items

--------------------------------------------------------------------------------

main :: IO ()
main = do
  cursor <- cursorFor forSaleForum
  checkedIds <- readFile checkedPosts

  let frontPageItemsIds = frontPageSaleIds $ getFrontPageSales cursor
  let checkedItemIds = splitOn "\n" checkedIds

  -- list of items noe yet checked yet
  let notYetChecked =frontPageItemsIds \\ checkedItemIds

  let toBeNotifiedOf = filter (\i -> postId i `elem` notYetChecked) $ getFrontPageSales cursor
  print toBeNotifiedOf


  --mapM_ (\itm -> appendFile checkedPosts $ itm ++ "\n") $ map postId $ getFrontPageSales cursor




  --frontPageIds <- map postId $ getFrontPageSales cursor
  --let uncheckedIds = frontPageSaleIds $ getFrontPageSales cursor \\ checkedIds
  --print $ lines uncheckedIds
  -- write to file
