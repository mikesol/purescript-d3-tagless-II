module D3.Examples.GUP where

import D3.Attributes.Sugar

import D3.Attributes.Instances (datumIsChar, indexIsNumber)
import D3.Data.Types (D3Selection_, Datum_, Element(..), Index_, Selector)
import D3Tagless.Capabilities (class SelectionM, appendElement, attach, (<+>))
import D3Tagless.Capabilities ((+)) as D3
import D3.Selection (ChainableS, Join(..), node, node_)
import Data.String.CodeUnits (singleton)
import Effect.Aff (Milliseconds(..))
import Prelude (bind, pure, ($), (*), (+), (<<<))

-- | ====================================================================================
-- | Simple-as-can-be example of the more complex Join which allows for new data to be
-- | entered, existing data to be updated and disappearing data to be removed
-- | ====================================================================================
type Model = Array Char

script3 :: forall m. SelectionM D3Selection_ m => Selector D3Selection_-> m ((Array Char) -> m D3Selection_)
script3 selector = do 
  root        <- attach selector
  svg         <- root D3.+ (node Svg [ viewBox 0.0 0.0 650.0 650.0, classed "d3svg gup" ])
  letterGroup <- svg  D3.+ (node Group [])

  pure $ \letters -> letterGroup <+> UpdateJoin Text letters { enter, update, exit }

  where 
    transition :: ChainableS
    transition = transitionWithDuration $ Milliseconds 2000.0

    xFromIndex :: Datum_ -> Index_ -> Number
    xFromIndex _ i = 50.0 + ((indexIsNumber i) * 48.0) -- letters enter at this position, and then must transition to new position on each update

    enter = [ classed  "enter"
            , fill     "green"
            , x        xFromIndex
            , y        0.0
            -- , yu (NWU { i: 0, u: Px })
            , text     (singleton <<< datumIsChar)
            , fontSize 96.0 ]  
          `andThen` (transition `to` [ y 200.0 ]) 

    update =  [ classed "update", fill "gray", y 200.0 ] 
              `andThen` (transition `to` [ x xFromIndex ] ) 

    exit =  [ classed "exit", fill "brown"] 
            `andThen` (transition `to` [ y 400.0, remove ])
