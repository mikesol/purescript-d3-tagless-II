module D3.FFI where

-- brings together ALL of the wrapped D3js functions and FFI / native types
-- TODO break this up into files corresponding to modules in D3js itself 
-- TODO move the type definitions for HierarchicalNode_ and SimulationNode_ etc to D3.Data.Native

import D3.Node

import D3.Data.Types (D3Data_, D3Selection_, D3Simulation_, Datum_, Element, Index_, PointXY, Selector, Transition, TreeJson_, TreeLayoutFn_, TreeType(..), ZoomConfigDefault_, ZoomConfig_)
import D3.FFI.Config (ForceCenterConfig_, ForceCollideConfig_, ForceCollideFixedConfig_, ForceLinkConfig_, ForceManyConfig_, ForceRadialConfig_, ForceRadialFixedConfig_, ForceXConfig_, ForceYConfig_, SimulationConfig_)
import Data.Array (find)
import Data.Function.Uncurried (Fn2)
import Data.Maybe (fromMaybe)
import Data.Nullable (Nullable)
import Prelude (Unit, unit, ($), (<$>))

-- | *********************************************************************************************************************
-- | ***************************   FFI signatures for D3js zoom module       *********************************************
-- | *********************************************************************************************************************
foreign import data ZoomBehavior_ :: Type  -- the zoom behavior, provided to Event Handler
foreign import d3AttachZoom_              :: D3Selection_ -> ZoomConfig_        -> D3Selection_
foreign import d3AttachZoomDefaultExtent_ :: D3Selection_ -> ZoomConfigDefault_ -> D3Selection_
foreign import showAttachZoomDefaultExtent_ :: forall selection. selection -> ZoomConfigDefault_ -> selection
foreign import showAttachZoom_              :: forall selection. selection -> ZoomConfig_ -> selection

-- | *********************************************************************************************************************
-- | ***************************   FFI signatures for Selection & Transition  ********************************************
-- | *********************************************************************************************************************
-- (Opaque) foreign types generated for (ie unsafeCoerce), or by (ie returned selections), D3 

foreign import d3SelectAllInDOM_     :: Selector    -> D3Selection_ -- NB passed D3Selection is IGNORED
foreign import d3SelectionSelectAll_ :: Selector    -> D3Selection_ -> D3Selection_
foreign import d3EnterAndAppend_     :: String      -> D3Selection_ -> D3Selection_
foreign import d3Append_             :: String      -> D3Selection_ -> D3Selection_

foreign import d3Exit_               :: D3Selection_ -> D3Selection_
foreign import d3RemoveSelection_    :: D3Selection_ -> D3Selection_

foreign import d3Data_               :: forall d. Array d -> D3Selection_ -> D3Selection_

type ComputeKeyFunction_ = Datum_ -> Index_
foreign import d3KeyFunction_        :: forall d. Array d -> ComputeKeyFunction_ -> D3Selection_ -> D3Selection_

-- we'll coerce everything to this type if we can validate attr lambdas against provided data
-- ... and we'll also just coerce all our setters to one thing for the FFI since JS don't care
foreign import data D3Attr :: Type 
-- NB D3 returns the selection after setting an Attr but we will only capture Selections that are 
-- meaningfully different _as_ selections, we're not chaining them in the same way
-- foreign import d3GetAttr_ :: String -> D3Selection -> ???? -- solve the ???? as needed later
foreign import d3AddTransition_ :: D3Selection_ -> Transition -> D3Selection_ -- this is the PS transition record
foreign import d3SetAttr_       :: String      -> D3Attr -> D3Selection_ -> D3Selection_
foreign import d3SetText_       :: D3Attr      -> D3Selection_ -> D3Selection_

foreign import emptyD3Data_ :: D3Data_ -- probably just null, could this be monoid too??? ie Last (Maybe D3Data_)

foreign import defaultDrag_ :: D3Selection_ -> D3Selection_
foreign import disableDrag_ :: D3Selection_ -> D3Selection_

-- show functions that are used for the string version of the interpreter and also for debugging inside Selection.js
foreign import showSelectAllInDOM_  :: forall selection. Selector -> String -> selection
foreign import showSelectAll_       :: forall selection. Selector -> String -> selection -> selection
foreign import showEnterAndAppend_  :: forall selection. Element -> selection -> selection
foreign import showExit_            :: forall selection. selection -> selection
foreign import showAddTransition_   :: forall selection. selection -> Transition -> selection 
foreign import showRemoveSelection_ :: forall selection. selection -> selection
foreign import showAppend_          :: forall selection. Element -> selection -> selection
foreign import showKeyFunction_     :: forall selection d. Array d -> ComputeKeyFunction_ -> selection -> selection
foreign import showData_            :: forall selection d. Array d -> selection -> selection
foreign import showSetAttr_         :: forall selection. String -> D3Attr -> selection -> selection
foreign import showSetText_         :: forall selection. D3Attr -> selection -> selection
foreign import selectionOn_         :: forall selection callback. selection -> String -> callback -> selection  


-- | *********************************************************************************************************************
-- | ***************************   FFI signatures for D3js Simulation module  *********************************************
-- | *********************************************************************************************************************
-- | foreign types associated with Force Layout Simulation

type GraphModel_ link node = { links :: Array link, nodes :: Array node }

foreign import initSimulation_  :: forall d.   Array d -> SimulationConfig_ -> D3Simulation_
foreign import getNodes_        :: forall d.   D3Simulation_ -> Array (D3_SimulationNode d)
foreign import getLinks_        :: forall d r. D3Simulation_ -> Array (D3_Link d r)
foreign import setNodes_        :: forall d.   D3Simulation_ -> Array (D3_SimulationNode d)     -> D3Simulation_
foreign import setLinks_        :: forall r.   D3Simulation_ -> Array (D3_Link NodeID r)     -> D3Simulation_
foreign import startSimulation_ :: D3Simulation_ -> Unit
foreign import stopSimulation_  :: D3Simulation_ -> Unit

foreign import pinNode_   :: forall d. Number -> Number -> D3_SimulationNode d -> Unit
foreign import unpinNode_ :: forall d. D3_SimulationNode d -> Unit
foreign import nanNodes_  :: forall d.  Array (D3_SimulationNode d) -> Unit

-- NB mutating function
pinNode :: forall d. D3_SimulationNode d -> PointXY -> D3_SimulationNode d
pinNode node p = do
  let _ = pinNode_ p.x p.y node
  node -- NB mutated value, fx / fy have been set

pinNodeMatchingPredicate :: forall d. Array (D3_SimulationNode d) -> ((D3_SimulationNode d) -> Boolean) -> Number -> Number -> Unit
pinNodeMatchingPredicate nodes predicate fx fy = fromMaybe unit $ (pinNode_ fx fy) <$> (find predicate nodes)


-- TODO this all has to change completely to work within Tagless 
-- foreign import data NativeSelection :: Type -- just temporarily defined to allow foreign functions to pass
-- foreign import addAttrFnToTick_           :: D3Selection_ -> D3Attr -> Unit
foreign import onTick_                :: D3Simulation_ -> String -> (Unit -> Unit) -> Unit
foreign import defaultSimulationDrag_ :: D3Selection_ -> D3Simulation_ -> Unit
foreign import setAlphaTarget_        :: D3Selection_ -> Number -> Unit

-- implementations / wrappers for the Force ADT
foreign import forceCenter_       :: D3Simulation_ -> ForceCenterConfig_       -> D3Simulation_
foreign import forceCollideFixed_ :: D3Simulation_ -> ForceCollideFixedConfig_ -> D3Simulation_
foreign import forceCollideFn_    :: D3Simulation_ -> ForceCollideConfig_      -> D3Simulation_
foreign import forceMany_         :: D3Simulation_ -> ForceManyConfig_         -> D3Simulation_
foreign import forceRadial_       :: D3Simulation_ -> ForceRadialConfig_       -> D3Simulation_
foreign import forceRadialFixed_  :: D3Simulation_ -> ForceRadialFixedConfig_  -> D3Simulation_
foreign import forceLink_         :: D3Simulation_ -> ForceLinkConfig_         -> D3Simulation_
foreign import forceX_            :: D3Simulation_ -> ForceXConfig_            -> D3Simulation_
foreign import forceY_            :: D3Simulation_ -> ForceYConfig_            -> D3Simulation_

-- | *********************************************************************************************************************
-- | ***************************   FFI signatures for D3js Hierarchy module  *********************************************
-- | *********************************************************************************************************************

-- this is an opaque type behind which hides the data type of the Purescript tree that was converted
foreign import data RecursiveD3TreeNode :: Type
-- this is the Purescript Tree after processing in JS to remove empty child fields from leaves etc
-- need to ensure that this structure is encapsulated in libraries (ie by moving this code)
foreign import data D3TreeLike_         :: Type -- covers both trees and clusters
foreign import data D3SortComparator_   :: Type -- a number such that n < 0 => a > b, n > 0 => b > a, n == 0 undef'd
foreign import data D3Hierarchical_     :: Type

foreign import hierarchyFromJSON_       :: forall d. TreeJson_ -> D3_TreeNode d
-- TODO now that these different hierarchy rows are composed at type level, polymorphic functions should be written
foreign import treeSortForCirclePack_   :: forall d. D3CirclePackRow d -> D3CirclePackRow d
foreign import treeSortForTreeMap_      :: forall d. D3TreeMapRow d -> D3TreeMapRow d
foreign import treeSortForTree_         :: forall d. D3_TreeNode d -> D3_TreeNode d

-- next some functions to make attributes, types are a bit sloppy here
-- TODO tighten this up
foreign import hasChildren_             :: Datum_ -> Boolean -- really only works on Datum_ when it's a D3HierarchicalNode_

-- the full API for hierarchical nodes:
foreign import descendants_     :: forall r. D3_TreeNode r -> Array (D3_TreeNode r)
foreign import find_            :: forall r. D3_TreeNode r -> (Datum_ -> Boolean) -> Nullable (D3_TreeNode r)
foreign import links_           :: forall d r1 r2. D3_TreeNode r1 -> Array (D3_Link d r2)

-- TODO implement the following as well
-- foreign import ancestors_    :: D3HierarchicalNode_ -> D3Data_
-- foreign import leaves_       :: D3HierarchicalNode_ -> Array D3HierarchicalNode_
-- foreign import path_         :: D3HierarchicalNode_ -> D3HierarchicalNode_ -> Array D3HierarchicalNode_

getLayout :: TreeType -> TreeLayoutFn_
getLayout layout = do
  case layout of
    TidyTree   -> getTreeLayoutFn_ unit
    Dendrogram -> getClusterLayoutFn_ unit

foreign import getTreeLayoutFn_       :: Unit -> TreeLayoutFn_
foreign import getClusterLayoutFn_    :: Unit -> TreeLayoutFn_

foreign import runLayoutFn_           :: forall r. TreeLayoutFn_ -> D3_TreeNode r -> D3_TreeNode r
foreign import treeSetSize_           :: TreeLayoutFn_ -> Array Number -> TreeLayoutFn_
foreign import treeSetNodeSize_       :: TreeLayoutFn_ -> Array Number -> TreeLayoutFn_
foreign import treeSetSeparation_     :: forall d. TreeLayoutFn_ -> (Fn2 (D3_TreeNode d) (D3_TreeNode d) Number) -> TreeLayoutFn_
foreign import treeMinMax_            :: forall d. D3_TreeNode d -> { xMin :: Number, xMax :: Number, yMin :: Number, yMax :: Number }
-- foreign import sum_                :: D3HierarchicalNode_ -> (Datum_ -> Number) -> D3HierarchicalNode_ -- alters the tree!!!!
-- from docs:  <<if you only want leaf nodes to have internal value, then return zero for any node with children. 
-- For example, as an alternative to node.count:
--        root.sum(function(d) { return d.value ? 1 : 0; });
-- foreign import count_              :: D3HierarchicalNode_ -> D3HierarchicalNode_ -- NB alters the tree!!!
-- foreign import sort_               :: D3HierarchicalNode_ -> (D3HierarchicalNode_ -> D3HierarchicalNode_ -> D3SortComparator_)
-- foreign import each_ -- breadth first traversal
-- foreign import eachAfter_ 
-- foreign import eachBefore_
-- foreign import deepCopy_ -- copies (sub)tree but shares data with clone !!!
foreign import sharesParent_          :: forall r. (D3_TreeNode r) -> (D3_TreeNode r) -> Boolean

foreign import linkHorizontal_        :: (Datum_ -> String) 
foreign import linkVertical_          :: (Datum_ -> String) 
foreign import linkClusterHorizontal_ :: Number -> (Datum_ -> String) 
foreign import linkClusterVertical_   :: Number -> (Datum_ -> String) 
foreign import linkRadial_            :: (Datum_ -> Number) -> (Datum_ -> Number) -> (Datum_ -> String)
foreign import autoBox_               :: Datum_ -> Array Number

-- accessors for fields of D3HierarchicalNode, only valid if layout has been done, hence the _XY version of node
-- REVIEW maybe accessors aren't needed if you can ensure type safety
foreign import hNodeDepth_  :: forall r. D3_TreeNode r -> Number
foreign import hNodeHeight_ :: forall r. D3_TreeNode r -> Number
foreign import hNodeX_      :: forall r. D3_TreeNode r -> Number
foreign import hNodeY_      :: forall r. D3_TreeNode r -> Number
