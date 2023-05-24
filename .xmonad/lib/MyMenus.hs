module MyMenus
    ( promptPass      -- * Retrieving passwords
    , promptPass' 
    , promptQuickmark -- * Launch favorite websites
    , promptNet       -- * Connect to network
    , promptWWW       -- * Web search
    , promptWWW'      -- * Web search (primary selection)
    , promptPower     -- * Power actions
    , promptSSH       -- * SSH connection
    ) where

import System.Environment
import System.Directory
import System.Exit (exitSuccess)
import System.FilePath (dropExtension, takeExtension)
import Data.List (isPrefixOf)

import XMonad.Core
import XMonad.Prompt ( XPrompt
                     , showXPrompt
                     , commandToComplete
                     , nextCompletion
                     , getNextCompletion
                     , XPConfig
                     , mkXPrompt
                     , searchPredicate)

import XMonad.Util.Run (runProcessWithInput,runInTerm)
import qualified XMonad.Actions.Search as S

-- General Variables
myQuickmarkFile = "quickmarks"
myNetScript     = "netctl.sh"
myPassScript    = "pass.sh"
myBrowser       = "brave"

archwiki, archpack, aurpack, wordref, rae :: S.SearchEngine
archwiki = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
archpack = S.searchEngine "archpack" "http://www.archlinux.org/packages/?q="
aurpack  = S.searchEngine "aurpack" "https://aur.archlinux.org/packages/?O=0&K="
wordref  = S.searchEngine "wordreference" "http://www.wordreference.com/es/translation.asp?tranword="
rae      = S.searchEngine "rae" "https://dle.rae.es/"

searchList :: [(String, S.SearchEngine)]
searchList = [ ("aw ArchWiki",      archwiki)
             , ("ar Arch Packages", archpack)
             , ("au AUR Packages",  aurpack)
             , ("wr WordReference", wordref)
             , ("ra RAE",           rae)
             , ("go Google",        S.google)
             , ("ho Hoogle",        S.hoogle)
             , ("im Images",        S.images)
             , ("yt YouTube",       S.youtube)
             , ("ha Hackage",       S.hackage)
             , ("ma Maps",          S.maps)
             , ("sc Scholar",       S.scholar)
             ]

cmdList :: [(String, X ())]
cmdList = [ ("Shutdown", spawn "systemctl poweroff")
          , ("Reboot",   spawn "systemctl reboot")
          , ("Hibernate",spawn "systemctl hibernate")
          , ("Suspend",  spawn "systemctl suspend")
          , ("Logout",   io exitSuccess)
          ]

-- General types
-- -------------
type Predicate = String -> String -> Bool
type PromptLabel = String
newtype MyPrompt = MyPrompt PromptLabel

instance XPrompt MyPrompt where
  showXPrompt       (MyPrompt prompt) = prompt ++ ": "
  commandToComplete _ c           = c
  nextCompletion      _           = getNextCompletion

-- General definitions
getPassCompl :: [String] -> Predicate -> String -> IO [String]
getPassCompl compls p s = return $ filter (p s) compls

mkMyPrompt :: PromptLabel -> [String] -> (String -> X ()) -> XPConfig -> X ()
mkMyPrompt promptLabel listOpts f xpconfig = do
    mkXPrompt (MyPrompt promptLabel) xpconfig (getPassCompl listOpts $ searchPredicate xpconfig) f

-- Password prompt
-- ---------------
promptPass :: XPConfig -> X ()
promptPass c = do 
    passwords <- io getPasswords
    myScript <- io $ getBasepath myPassScript
    let cmd s | "F2A" `isPrefixOf` s = spawn $ "pass otp "++s++" | "++myScript
              | otherwise = spawn $ "pass "++s++" | "++myScript
    mkMyPrompt "Password menu" passwords cmd c

promptPass' :: XPConfig -> X ()
promptPass' c = do 
    passwords <- io getPasswords
    myScript <- io $ getBasepath myPassScript
    let cmd s = spawn $ "pass "++s++" | "++myScript++" username"
    mkMyPrompt "Password menu" passwords cmd c

-- Quickmark prompt
-- ----------------
promptQuickmark :: XPConfig -> X ()
promptQuickmark c = do
    listOpts <- io getQuickmarks
    let cmd s = spawn $ (myBrowser++) . (" "++) . head . tail . words $ s
    mkMyPrompt "Bookmark menu" listOpts cmd c

-- Network prompt
-- --------------
promptNet :: XPConfig -> X ()
promptNet c = do
    contents <- runProcessWithInput "bash" [] "netctl list | sed 's/^[ ,*]*//g'"
    myScript <- io $ getBasepath myNetScript
    let cmd s = spawn $ myScript++" "++s
        listOpts = lines contents
    mkMyPrompt "Network menu" listOpts cmd c

-- Launch browser: use input query
-- --------------
promptWWW :: XPConfig -> X ()
promptWWW c = do
    let cmd s = S.promptSearch c f where Just f = lookup s searchList
        listOpts = map fst searchList
    mkMyPrompt "Select engine" listOpts cmd c

-- Launch browser: use primary selection
-- --------------
promptWWW' :: XPConfig -> X ()
promptWWW' c = do
    let cmd s = S.selectSearch f where Just f = lookup s searchList
        listOpts = map fst searchList
    mkMyPrompt "Select engine" listOpts cmd c

-- Power prompt
-- ------------
promptPower :: XPConfig -> X ()
promptPower c = do 
    let cmd s = promptConfirmation c f where Just f = lookup s cmdList
        listOpts = map fst cmdList
    mkMyPrompt "Power menu" listOpts cmd c

-- Confirmation prompt
-- -------------------
promptConfirmation :: XPConfig -> X () -> X ()
promptConfirmation c f = do
    let cmd "No" = return ()
        cmd _ = f 
        listOpts = ["Yes","No"]
    mkMyPrompt "Are you sure?" listOpts cmd c

-- SSH prompt
-- -------------------
promptSSH :: XPConfig -> X ()
promptSSH c = do
    listOpts <- io sshComplList
    let cmd = runInTerm "" . ("ssh " ++ )
    mkMyPrompt "SSH menu" listOpts cmd c

-- Auxiliary functions
-- -------------------
getBasepath :: FilePath -> IO FilePath
getBasepath fname = do
    h <- getEnv "HOME"
    return $ h ++ "/.xmonad/" ++ fname

getPasswords :: IO [String]
getPasswords = do
  h <- getEnv "HOME"
  let passwordStoreDir = h ++ "/.password-store"
  files <- runProcessWithInput "find" [
    "-L", -- Traverse symlinks
    passwordStoreDir,
    "-type", "f",
    "-name", "*.gpg",
    "-printf", "%P\n"] []
  return . map removeGpgExtension $ lines files

removeGpgExtension :: String -> String
removeGpgExtension file | takeExtension file == ".gpg" = dropExtension file
                        | otherwise                    = file

getQuickmarks :: IO [String]
getQuickmarks = do
  fname <- getBasepath myQuickmarkFile
  l <- readFile fname
  return $ lines l

sshComplList :: IO [String]
sshComplList = do
    h <- getEnv "HOME"
    let fname = h ++ "/.ssh/config"
    f <- doesFileExist fname
    if f then do
              l <- readFile fname
              return $ map (!!1)
                     $ filter isHost
                     $ map words
                     $ lines l
         else return []
    where
        isHost ws = take 1 ws == ["Host"] && length ws > 1
