{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_dummy_package (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath



bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/home/lucas_ellenberger/base-autograder-image/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e0935a4617ca9269e08edbb8b1996fa98021ab48aa38f9efa42bfbd19604f933/9.4.7/bin"
libdir     = "/home/lucas_ellenberger/base-autograder-image/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e0935a4617ca9269e08edbb8b1996fa98021ab48aa38f9efa42bfbd19604f933/9.4.7/lib/x86_64-linux-ghc-9.4.7/dummy-package-0.1.0.0-8PxeXlpSG9RLHMD7OlPTXv-dummy-package"
dynlibdir  = "/home/lucas_ellenberger/base-autograder-image/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e0935a4617ca9269e08edbb8b1996fa98021ab48aa38f9efa42bfbd19604f933/9.4.7/lib/x86_64-linux-ghc-9.4.7"
datadir    = "/home/lucas_ellenberger/base-autograder-image/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e0935a4617ca9269e08edbb8b1996fa98021ab48aa38f9efa42bfbd19604f933/9.4.7/share/x86_64-linux-ghc-9.4.7/dummy-package-0.1.0.0"
libexecdir = "/home/lucas_ellenberger/base-autograder-image/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e0935a4617ca9269e08edbb8b1996fa98021ab48aa38f9efa42bfbd19604f933/9.4.7/libexec/x86_64-linux-ghc-9.4.7/dummy-package-0.1.0.0"
sysconfdir = "/home/lucas_ellenberger/base-autograder-image/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e0935a4617ca9269e08edbb8b1996fa98021ab48aa38f9efa42bfbd19604f933/9.4.7/etc"

getBinDir     = catchIO (getEnv "dummy_package_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "dummy_package_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "dummy_package_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "dummy_package_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "dummy_package_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "dummy_package_sysconfdir") (\_ -> return sysconfdir)




joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
