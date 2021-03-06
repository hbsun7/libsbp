{-# OPTIONS_GHC -fno-warn-unused-imports #-}
{-# LANGUAGE NoImplicitPrelude           #-}
{-# LANGUAGE TemplateHaskell             #-}

-- |
-- Module:      SwiftNav.SBP.TH
-- Copyright:   Copyright (C) 2015 Swift Navigation, Inc.
-- License:     LGPL-3
-- Maintainer:  Mark Fine <dev@swiftnav.com>
-- Stability:   experimental
-- Portability: portable
--
-- Templated generation of SBP interfaces.

module SwiftNav.SBP.TH where

import BasicPrelude
import Control.Lens
import Data.Binary
import Data.ByteString
import Data.ByteString.Lazy hiding (ByteString)
import Language.Haskell.TH
import SwiftNav.SBP.Types
import Control.Exception.Base (assert)

-- | Derive ToSBP typeclass, given an SBP message type name and the
-- name of the implemented type.
deriveSBP :: Name -> Name -> Q [Dec]
deriveSBP msgType name =
  [d|instance ToSBP $(conT name) where
       toSBP m senderID = encoded & msgSBPCrc .~ checkCrc encoded
         where
           payload = toStrict $ encode m
           len' = Data.ByteString.length payload
           len = assert (len' < 256) $ fromIntegral len'
           encoded = Msg $(varE msgType) senderID len payload 0
    |]
