------------------------------------------------------------------------
-- IMPORTS
------------------------------------------------------------------------
    -- System
import System.IO (hPutStrLn)

    -- Data
import Data.Monoid
import Data.List (isPrefixOf)
import qualified Data.Map as M

    -- Xmonad base
import XMonad
import qualified XMonad.StackSet as W

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (docks, avoidStruts, manageDocks)
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.WindowSwallowing

    -- Layouts modifiers
import XMonad.Layout.ShowWName
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Renamed 
import XMonad.Layout.Tabbed
import XMonad.Layout.SubLayouts
import XMonad.Layout.Simplest
import XMonad.Layout.NoBorders
import qualified XMonad.Layout.WindowNavigation as WN

    -- Prompt
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch (fuzzyMatch,fuzzySort)
import XMonad.Prompt.Shell (shellPrompt)

    -- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (spawnPipe,runProcessWithInput)
import XMonad.Util.SpawnOnce (spawnOnce)

    -- My modules
import qualified MyMenus as MM
------------------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------------------
myFont :: String
myFont = "xft:DejaVuSansMono:size=15:antialias=true"

myModMask :: KeyMask
myModMask = mod4Mask   -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "urxvt"   -- Sets default terminal

myBrowser :: String
myBrowser = "brave"    -- Sets default browser

myMail :: String
myMail = myTerminal ++ " -name neomutt -e neomutt"

myEditor :: String
myEditor = myTerminal ++ " -e vim"    -- Sets default editor

myBorderWidth :: Dimension
myBorderWidth = 3          -- Sets border width for windows

myNormColor :: String
myNormColor   = "#282c34"  -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#F9E79F"  -- Border color of focused windows

myTextColor :: String
myTextColor = "#d0d0d0"    -- Text color

------------------------------------------------------------------------
-- AUTOSTART
------------------------------------------------------------------------
myStartupHook :: X ()
myStartupHook = do
          spawnOnce "~/.fehbg &"  -- set wallpaper
          setWMName "LG3D"

------------------------------------------------------------------------
-- XPROMPT SETTINGS
------------------------------------------------------------------------
myXPConfig :: XPConfig
myXPConfig = def
      { font                = myFont
      , bgColor             = myNormColor
      , fgColor             = myTextColor
      , bgHLight            = myFocusColor
      , fgHLight            = myNormColor
      , borderColor         = myNormColor
      , promptBorderWidth   = 0
      , height              = 25
      , autoComplete        = Just 100000
      , showCompletionOnTab = False
      , searchPredicate     = fuzzyMatch
      , sorter              = fuzzySort
      , alwaysHighlight     = True
      , historySize         = 0
      , promptKeymap        = vimLikeXPKeymap
      , maxComplRows        = Nothing      -- set to Just 5 for 5 rows
      }

------------------------------------------------------------------------
-- WORKSPACES
------------------------------------------------------------------------
myWorkspaces = ["1: \61728", "2: \62059", "3: \xf0e0", "4: \61564"] ++ map show [5..9]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] 

------------------------------------------------------------------------
-- MANAGEHOOK
------------------------------------------------------------------------
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     [ className =? "Brave-browser"   --> doShift ( myWorkspaces !! 1 )
     , title =?     "neomutt"         --> doShift ( myWorkspaces !! 2 )
     , className =? "pinentry-qt"     --> doFloat
     ] <+> namedScratchpadManageHook myScratchPads

------------------------------------------------------------------------
-- LAYOUTS
------------------------------------------------------------------------
-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = myFocusColor
                 , inactiveColor       = myNormColor
                 , activeBorderColor   = myFocusColor
                 , inactiveBorderColor = myFocusColor
                 , activeTextColor     = myNormColor
                 , inactiveTextColor   = myTextColor
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:DejaVuSansMono:size=60:antialias=true, Font Awesome 6 Free Solid:style=Solid:size=50, Font Awesome 6 Brands Regular:style=Regular:size=50"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1c1f24"
    , swn_color             = "#00ffff"
    }

myLayoutHook = avoidStruts $ onWorkspace (myWorkspaces!!2) myLayoutH $ myLayoutV
  where
    myLayoutH = hsplit ||| vsplit ||| tabs ||| fullsc
    myLayoutV = vsplit ||| hsplit ||| tabs ||| fullsc
    -- default tiling algorithm partitions the screen into two panes
    vsplit = renamed [Replace "vsplit"] 
             $ lessBorders Screen
             $ WN.windowNavigation
             $ addTabs shrinkText myTabTheme
             $ subLayout [] Simplest
             $ Tall nmaster delta ratio
    hsplit = renamed [Replace "hsplit"]
             $ lessBorders Screen
             $ WN.windowNavigation
             $ addTabs shrinkText myTabTheme
             $ subLayout [] Simplest
             $ Mirror vsplit
    tabs   = renamed [Replace "tabbed"]
             $ noBorders
             $ tabbed shrinkText myTabTheme
    fullsc = renamed [Replace "full"]
             $ noBorders
             $ Full

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100

------------------------------------------------------------------------
-- SCRATCHPADS
------------------------------------------------------------------------
myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm ]
  where
    spawnTerm  = myTerminal ++ " -name scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.5
                 t = 0.5*h
                 l = 0.5*w

------------------------------------------------------------------------
-- KEYBINDINGS
------------------------------------------------------------------------
myKeys :: [(String, X ())]
myKeys =
        [ 
    -- Open my preferred terminal
          ("M-<Return>", spawn myTerminal)           -- launch a terminal

    -- Windows navigation
        , ("M-S-m", windows W.swapMaster)            -- Swap the focused window and the master window

    -- Apps
        , ("M-<F2>", spawn myBrowser)
        , ("M-<F3>", spawn myMail)

    -- Scratchpads
        , ("M-t", namedScratchpadAction myScratchPads "terminal")

    -- Sublayouts
        , ("M-C-h", sendMessage $ pullGroup WN.L)
        , ("M-C-l", sendMessage $ pullGroup WN.R)
        , ("M-C-k", sendMessage $ pullGroup WN.U)
        , ("M-C-j", sendMessage $ pullGroup WN.D)
        , ("M-C-u", withFocused (sendMessage . UnMerge))

    -- floating layer support
        , ("M-S-t", withFocused $ windows . W.sink)   --  Push window back into tiling

    -- Prompts
        , ("M-b",       MM.promptQuickmark myXPConfig { searchPredicate = isPrefixOf })
        , ("M-o",       MM.promptWWW       myXPConfig { searchPredicate = isPrefixOf })
        , ("M-S-o",     MM.promptWWW'      myXPConfig { searchPredicate = isPrefixOf })
        , ("M-S-<Esc>", MM.promptPower     myXPConfig)
        , ("M-S-<F2>",  MM.promptNet       myXPConfig)
        , ("M-p",       MM.promptPass      myXPConfig)
        , ("M-S-p",     MM.promptPass'     myXPConfig)
        , ("M-s",       MM.promptSSH       myXPConfig)
        , ("M-d",       shellPrompt        myXPConfig) 
        ]

------------------------------------------------------------------------
-- MAIN
------------------------------------------------------------------------
main :: IO ()
main = do
    -- Launching three instances of xmobar on their monitors.
    xmproc <- spawnPipe "xmobar -x 0 ~/.xmonad/xmobarrc"
    xmonad $ ewmh $ docks $ def
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
        , handleEventHook    = swallowEventHook (className =? "URxvt") (return True)
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = workspaceHistoryHook <+>  dynamicLogWithPP xmobarPP
                        { ppOutput = \x -> hPutStrLn xmproc x  
                        -- Current workspace in xmobar
                        , ppCurrent = xmobarColor "#c3e88d" "" . wrap "<box type=Bottom width=2>" "</box>" 
                        -- Visible but not current workspace
                        , ppVisible = xmobarColor "#c3e88d" ""
                        -- Title of active window in xmobar
                        , ppTitle = xmobarColor myTextColor "" . shorten 60
                        -- Separators in xmobar
                        , ppSep =  "<fc=#666666> | </fc>"
                        -- Urgent workspace
                        , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"
                        }
        } `additionalKeysP` myKeys
