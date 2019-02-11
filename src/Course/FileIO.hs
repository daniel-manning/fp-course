{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RebindableSyntax #-}

module Course.FileIO where

import Course.Core
import Course.Applicative
import Course.Monad
import Course.Functor
import Course.List

{-

Useful Functions --

  getArgs :: IO (List Chars)
  putStrLn :: Chars -> IO ()
  readFile :: FilePath -> IO Chars
  lines :: Chars -> List Chars
  void :: IO a -> IO ()

Abstractions --
  Applicative, Monad:

    <$>, <*>, >>=, =<<, pure

Tuple Functions that could help --

  fst :: (a, b) -> a
  snd :: (a, b) -> b
  (,) :: a -> b -> (a, b)

Problem --
  Given a single argument of a file name, read that file,
  each line of that file contains the name of another file,
  read the referenced file and print out its name and contents.

Consideration --
  Try to avoid repetition. Factor out any common expressions.

Example --
Given file files.txt, containing:
  a.txt
  b.txt
  c.txt

And a.txt, containing:
  the contents of a

And b.txt, containing:
  the contents of b

And c.txt, containing:
  the contents of c

To test this module, load ghci in the root of the project directory, and do
    >> :main "share/files.txt"

Example output:

$ ghci
GHCi, version ...
Loading package...
Loading ...
[ 1 of 28] Compiling (etc...
...
Ok, modules loaded: Course, etc...
>> :main "share/files.txt"
============ share/a.txt
the contents of a

============ share/b.txt
the contents of b

============ share/c.txt
the contents of c

-}

-- Given the file name, and file contents, print them.
-- Use @putStrLn@.
printFile ::
  FilePath
  -> Chars
  -> IO ()
printFile fp c =  foldRight (\a _ -> putStrLn a) (pure ()) (("============ " ++ fp) :. c :. Nil)

-- Given a list of (file name and file contents), print each.
-- Use @printFile@.
printFiles ::
  List (FilePath, Chars)
  -> IO ()
printFiles = foldRight (\a _ -> printFile (fst a) (snd a)) (pure ())

-- Given a file name, return (file name and file contents).
-- Use @readFile@.
getFile ::
  FilePath
  -> IO (FilePath, Chars)
getFile fp = ((,) fp) <$> readFile fp


-- Given a list of file names, return list of (file name and file contents).
-- Use @getFile@.
getFiles ::
  List FilePath
  -> IO (List (FilePath, Chars))
getFiles lfp =  sequence $ getFile <$> lfp

-- Given a file name, read it and for each line in that file, read and print contents of each.
-- Use @getFiles@, @lines@, and @printFiles@.
run ::
  FilePath
  -> IO ()
run fp =  printFiles =<< getFiles =<< pure (\a -> lines $ snd a) <*> getFile fp

-- /Tip:/ use @getArgs@ and @run@
main ::
  IO ()
main = (foldRight (\b c -> run b) (pure ())) =<< getArgs

--getArgs :: IO (List Chars)

----

-- Was there was some repetition in our solution?
-- ? `sequence . (<$>)`
-- ? `void . sequence . (<$>)`
-- Factor it out.
