module D3.Layouts.Simulation where

import D3.Node

import D3.Data.Types (D3Simulation_)
import D3.FFI (forceCenter_, forceCollideFixed_, forceCollideFn_, forceCustom_, forceLink_, forceMany_, forceRadialFixed_, forceRadial_, forceX_, forceY_)
import D3.FFI.Config (CustomForceConfig(..), D3ForceHandle_, ForceCenterConfig_, ForceCollideConfig_, ForceCollideFixedConfig_, ForceLinkConfig_, ForceManyConfig_, ForceRadialConfig_, ForceRadialFixedConfig_, ForceXConfig_, ForceYConfig_, SimulationConfig_)
import D3.Selection (DragBehavior)
import Data.Maybe (Maybe)
import Prelude (Unit)

type SimulationManager d l = (  
-- 'd' is the type of the "data" field in each node
-- 'l' is the additional row-types in the link
    label      :: String
  , simulation :: Maybe D3Simulation_
  , config     :: SimulationConfig_
  , nodes      :: Array (D3SimulationRow d)
  , idLinks    :: Array (D3_Link NodeID l)
  , objLinks   :: Array (D3_Link (D3SimulationRow d) l)
  , forces     :: Array D3ForceHandle_
  , tick       :: Unit -> Unit -- could be Effect Unit??
  , drag       :: DragBehavior -- TODO make strongly typed wrt actual Model used
)

data Force =
    ForceManyBody     ForceManyConfig_
  | ForceCenter       ForceCenterConfig_
  | ForceCollideFixed ForceCollideFixedConfig_
  | ForceCollide      ForceCollideConfig_
  | ForceX            ForceXConfig_
  | ForceY            ForceYConfig_
  | ForceRadialFixed  ForceRadialFixedConfig_
  | ForceRadial       ForceRadialConfig_
  | ForceLink         ForceLinkConfig_
  | CustomForce       (forall r. { name :: String | r })

createForce :: Force -> D3ForceHandle_
createForce = 
  case _ of
    (ForceManyBody config) ->
      forceMany_ config 
    (ForceCenter config) ->
      forceCenter_ config
    (ForceCollideFixed config) ->
      forceCollideFixed_ config
    (ForceCollide config) ->
      forceCollideFn_ config
    (ForceX config) ->
      forceX_ config
    (ForceY config) ->
      forceY_ config
    (ForceRadialFixed config) ->
      forceRadialFixed_ config
    (ForceRadial config) ->
      forceRadial_ config
    (ForceLink config) ->
      forceLink_ config
       
    (CustomForce config) -> 
      forceCustom_ config
