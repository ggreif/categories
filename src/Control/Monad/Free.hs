{-# OPTIONS -fglasgow-exts #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Control.Monad.Free
-- Copyright   :  (C) 2008 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  experimental
-- Portability :  portable
--
----------------------------------------------------------------------------
module Control.Monad.Free where

import Control.Monad
import Control.Arrow ((|||), (&&&), (+++), (***))

-- | The free monad of a functor
data Free f a = Free { runFree :: Either a (f (Free f a)) }

instance Functor f => Functor (Free f) where
        fmap f = Free . (f +++ fmap (fmap f)) . runFree

instance Functor f => Monad (Free f) where
        return = Free . Left
        m >>= k = (k ||| (inFree . fmap (>>= k))) (runFree m)

inFree :: f (Free f a) -> Free f a
inFree = Free . Right

cataFree :: Functor f => (c -> a) -> (f a -> a) -> Free f c -> a
cataFree l r = (l ||| r . fmap (cataFree l r)) . runFree