import System.Environment
import System.Directory
import System.IO
import System.IO.Error
import Data.List
import System.Cmd

import qualified Data.Map as Map  

main = do
  (arg:other) <- getArgs
  dirs <- getDirectoryContents "."
  handleArg arg dirs
  
handleArg "continue" dirs = (continue dirs) `catch` errHandler
handleArg ep dirs = watchEps ep dirs  

watchEps episodeNo dirs = do
  let results = zip [1 .. ] (filter (findInString episodeNo) dirs)
      resultMap = Map.fromList $ results
      options = unlines $ map option results
      option a = show (fst a) ++ ". " ++ (snd a)
  putStrLn $ unlines (map (\a -> option a) results)
  putStrLn "Choose an option dude : "
  chosen <- getLine
  success <- handleLookup (Map.lookup (read chosen) resultMap) episodeNo
  if success 
    then do
           putStrLn "Watch the next episode?"
           watchEps (epPlusOne episodeNo) dirs 
  else watchEps episodeNo dirs

handleLookup (Just x) ep = do
  writeFile ".series_continue" ep 
  rawSystem "mplayer" [x]
  putStrLn $ "done with " ++ x
  return True
handleLookup Nothing ep = do
  putStrLn "Pick something dumbass"
  return False
  

findInString :: String -> String -> Bool
findInString needle haystack = foldl foldFunc False (tails haystack)
  where foldFunc acc item = acc || ((take len item) == needle)
        len = length needle

epPlusOne :: String -> String
epPlusOne ep = show $ (read ep) + 1

continue dirs = do
  contents <- readFile ".series_continue"
  let episodeNo = head $ lines contents
      handle "y" ep = watchEps (epPlusOne ep) dirs
      handle "n" ep = watchEps ep dirs            
  putStrLn $ "Did you finish watching " ++ episodeNo ++ " [y/n]"
  yn <- getLine
  handle yn episodeNo
  
errHandler :: IOError -> IO ()
errHandler e
       | isDoesNotExistError e = putStrLn "You do not have a continue file yet"
       | otherwise = ioError e