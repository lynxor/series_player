import System.Environment
import System.Directory
import System.IO
import System.IO.Error
import Data.List
import System.Cmd
import Search
import Data.Function (on)

import qualified Data.Map as Map  

main = do
  (arg:other) <- getArgs
  dirs <- getDirectoryContents "."
  handleArg arg dirs
  
handleArg "--prev" dirs = prev dirs
handleArg "--continue" dirs = (continue dirs) `catch` errHandler
handleArg ep dirs = watchEps ep dirs  

isVideoFile fileName = any (isEndOf fileName) videoFiles
    where videoFiles = ["mkv", "avi", "mp4", "mpg"]
          isEndOf = flip endsWith

watchEps episodeNo dirs = do
  let unsorted = filter isVideoFile (filter (findInString episodeNo) dirs)
      results = zip [1 ..] $ reverse $ sortBy (compare `on` (searchEpNo (read episodeNo))) unsorted
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
  


epPlusOne :: String -> String
epPlusOne ep = show $ (read ep) + 1

prev dirs = do
  contents <- readFile ".series_continue"
  let episodeNo = show $ (read (head ( lines contents))) - 1
  putStrLn $ "Starting previous: " ++ episodeNo ++ " .."
  watchEps episodeNo dirs

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
       | isDoesNotExistError e = do
               putStrLn "You do not have a continue file yet, starting at episode 1"
               dirs <- getDirectoryContents "."
               watchEps (show 1) dirs
       | otherwise = ioError e