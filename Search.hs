module Search
(
 searchEpNo,
 findInString,
 endsWith
) where

import Text.Regex.Posix
import Data.List

-- returns a score out of ten on how likely match this is
searchEpNo :: (Fractional a) => Int -> String -> a 
searchEpNo e f = (fromIntegral added) / 3
    where added = (plainMatch e f) + (seriesMatch e f) + (separatedMatch e f)
                           

plainMatch :: Int -> String -> Int
plainMatch epNo fileName =  if (findInString (show epNo) fileName) 
                              then 10 
                            else 0

seriesMatch :: Int -> String -> Int
seriesMatch epNo fileName = if fileName =~ regex then 10 else 0
    where regex = "S[0-9]{2}E0?" ++ (show epNo)

separatedMatch :: Int -> String -> Int
separatedMatch epNo fileName = if (fileName =~ ("\\s0?" ++ (show epNo) ++ "[\\s\\.\\-\\(]")) 
                                  then 10 
                               else 0

endsWith :: String -> String -> Bool
endsWith needle haystack = haystack =~ (needle ++ "$")

findInString :: String -> String -> Bool
findInString needle haystack = haystack =~ regex
                               where regex = "([^1-9])0?" ++ needle ++ "([^1-9])"
    
                               