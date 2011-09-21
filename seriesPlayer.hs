import System.Environment
import System.Directory
import Data.List
import System.Cmd
import qualified Data.Map as Map  

main = do
  (episodeNo:other) <- getArgs
  dirs <- getDirectoryContents "."
  let results = zip [1 .. ] (filter (findInString episodeNo) dirs)
      resultMap = Map.fromList $ results
      options = unlines $ map option results
      option a = show (fst a) ++ ". " ++ (snd a)
  putStrLn $ unlines (map (\a -> option a) results)
  putStrLn "Choose an option dude : "
  chosen <- getLine
  rawSystem "mplayer" [handleLookup(Map.lookup (read chosen) resultMap)] 

handleLookup (Just x) = x
handleLookup Nothing = "Pick something dumbass"
  

findInString :: String -> String -> Bool
findInString needle haystack = foldl foldFunc False (tails haystack)
  where foldFunc acc item = acc || ((take len item) == needle)
        len = length needle
