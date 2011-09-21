import System.Environment
import System.Directory
import Data.List
import System.Cmd
import qualified Data.Map as Map  

main = do
  (episodeNo:other) <- getArgs
  dirs <- getDirectoryContents "."
  watchEps episodeNo dirs
  

watchEps episodeNo dirs = do
  let results = zip [1 .. ] (filter (findInString episodeNo) dirs)
      resultMap = Map.fromList $ results
      options = unlines $ map option results
      option a = show (fst a) ++ ". " ++ (snd a)
  putStrLn $ unlines (map (\a -> option a) results)
  putStrLn "Choose an option dude : "
  chosen <- getLine
  success <- handleLookup(Map.lookup (read chosen) resultMap)
  if success 
    then do
           putStrLn "Watch the next episode?"
           watchEps (show ((read episodeNo) + 1)) dirs 
  else watchEps episodeNo dirs

handleLookup (Just x) = do
  rawSystem "mplayer" [x]
  putStrLn $ "done with " ++ x
  return True
handleLookup Nothing = do
  putStrLn "Pick something dumbass"
  return False
  

findInString :: String -> String -> Bool
findInString needle haystack = foldl foldFunc False (tails haystack)
  where foldFunc acc item = acc || ((take len item) == needle)
        len = length needle
