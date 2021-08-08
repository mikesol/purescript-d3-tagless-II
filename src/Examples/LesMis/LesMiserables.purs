module D3.Examples.LesMiserables where

import Affjax as AJAX
import Affjax.ResponseFormat as ResponseFormat
import Control.Monad.State (class MonadState)
import D3.Attributes.Sugar (classed, cx, cy, fill, radius, strokeColor, strokeOpacity, strokeWidth, viewBox, x1, x2, y1, y2)
import D3.Data.Types (D3Selection_, Datum_, Element(..), Selector)
import D3.Examples.LesMis.Unsafe (unboxD3SimLink, unboxD3SimNode)
import D3.Examples.LesMiserables.File (readGraphFromFileContents)
import D3.Examples.LesMiserables.Model (LesMisRawModel)
import D3.Scales (d3SchemeCategory10N_)
import D3.Selection (Behavior(..), DragBehavior(..), Join(..), node)
import D3.Simulation.Config as F
import D3.Simulation.Forces (createForce)
import D3.Simulation.Functions (simulationCreateTickFunction, simulationSetLinks, simulationSetNodes)
import D3.Simulation.Types (Force, ForceType(..), SimVariable(..), D3SimulationState_, Step(..), initialSimulationState)
import D3.Zoom (ScaleExtent(..), ZoomExtent(..))
import D3Tagless.Capabilities (class SelectionM, class SimulationM, attach, addTickFunction, defaultLinkTick, defaultNodeTick, join, on, setConfigVariable, setLinks, setNodes, start)
import D3Tagless.Capabilities as D3
import Data.Int (toNumber)
import Data.Nullable (Nullable)
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console (log)
import Math (sqrt)
import Prelude (class Bind, Unit, bind, discard, negate, pure, unit, ($), (/), (<<<))
import Utility (getWindowWidthHeight)

-- type-safe(ish) accessors for the data that is given to D3
-- we lose the type information in callbacks from the FFI, such as for attributes
-- but since we know what we gave we can coerce it back to the initial type.
link_ = {
    source: \d -> (unboxD3SimLink d).source
  , target: \d -> (unboxD3SimLink d).target
  , value:  \d -> (unboxD3SimLink d).value
  , color:  \d -> d3SchemeCategory10N_ (toNumber $ (unboxD3SimLink d).target.group)
}

datum_ = {
-- direct accessors to fields of the datum (BOILERPLATE)
    id    : \d -> (unboxD3SimNode d).id
  , x     : \d -> (unboxD3SimNode d).x
  , y     : \d -> (unboxD3SimNode d).y
  , group : \d -> (unboxD3SimNode d).group

  , colorByGroup:
      \d -> d3SchemeCategory10N_ (toNumber $ datum_.group d)
}

-- | recipe for this force layout graph
graphScript :: forall row m. 
  Bind m => 
  MonadEffect m =>
  MonadState { simulationState :: D3SimulationState_ | row } m => 
  SimulationM D3Selection_ m =>
  LesMisRawModel -> Selector D3Selection_ -> m Unit
graphScript model selector = do
  (Tuple w h) <- liftEffect getWindowWidthHeight
  (root :: D3Selection_) <- attach selector
  svg        <- root D3.+ (node Svg [ viewBox (-w / 2.0) (-h / 2.0) w h
                                               , classed "lesmis" ] )
  linksGroup <- svg  D3.+ (node Group  [ classed "link", strokeColor "#999", strokeOpacity 0.6 ])
  nodesGroup <- svg  D3.+ (node Group  [ classed "node", strokeColor "#fff", strokeOpacity 1.5 ])
  
  -- in contrast to a simple SelectionM function, we have additional typeclass capabilities for simulation
  -- which we use here to introduce the nodes and links to the simulation
  simulationNodes <- setNodes model.nodes
  simulationLinks <- setLinks model.links datum_.id -- the "links" force will already be there
  
  -- joining the data from the model after it has been put into the simulation
  linksSelection <- linksGroup D3.<+> Join Line   simulationLinks [ strokeWidth (sqrt <<< link_.value), strokeColor link_.color ]
  nodesSelection <- nodesGroup D3.<+> Join Circle simulationNodes [ radius 5.0, fill datum_.colorByGroup ]

  -- both links and nodes are updated on each step of the simulation, 
  -- in this case it's a simple translation of underlying (x,y) data for the circle centers
  -- tick functions have names, in this case "nodes" and "links"
  addTickFunction "nodes" $ Step nodesSelection [ cx datum_.x, cy datum_.y  ]
  addTickFunction "links" $ Step linksSelection [ x1 (_.x <<< link_.source)
                                                , y1 (_.y <<< link_.source)
                                                , x2 (_.x <<< link_.target)
                                                , y2 (_.y <<< link_.target)
                                                ]
  _ <- nodesSelection `on` Drag DefaultDrag

  _ <- svg `on`  Zoom { extent : ZoomExtent { top: 0.0, left: 0.0 , bottom: h, right: w }
                      , scale  : ScaleExtent 1.0 4.0 -- wonder if ScaleExtent ctor could be range operator `..`
                      , name   : "LesMis"
                      , target : svg
                      }

  pure unit
