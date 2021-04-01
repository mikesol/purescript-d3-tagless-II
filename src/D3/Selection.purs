module D3.Selection where

import Prelude hiding (append,join)

import D3.Attributes.Instances (Attrib, Attribute, Datum, Index)
import Data.Maybe (Maybe)
import Data.Maybe.First (First)
import Data.Time.Duration (Milliseconds)
import Data.Tuple (Tuple)
import Unsafe.Coerce (unsafeCoerce)


type Selector = String 

data Element = Div | Svg | Circle | Line | Group | Text
instance showElement :: Show Element where
  show Div    = "div"
  show Svg    = "svg"
  show Circle = "circle"
  show Line   = "line"
  show Group  = "g"
  show Text   = "text"
  
-- || trying this with Finally Tagless instead of interpreter
foreign import data D3Selection_  :: Type
type D3Selection = First D3Selection_
foreign import data D3DomNode    :: Type
foreign import data D3This       :: Type
type KeyFunction = Datum -> Index
type D3Group = Array D3DomNode
foreign import data D3Transition :: Type -- not clear yet if we need to distinguish from Selection
-- we'll coerce everything to this type if we can validate attr lambdas against provided data
foreign import data D3Data :: Type 
-- ... and we'll also just coerce all our setters to one thing for the FFI since JS don't care
foreign import data D3Attr :: Type 

foreign import d3SelectAllInDOM_     :: Selector -> D3Selection -- NB passed D3Selection is IGNORED
foreign import d3SelectionSelectAll_ :: Selector -> D3Selection -> D3Selection
foreign import d3EnterAndAppend_     :: String   -> D3Selection -> D3Selection
foreign import d3Append_             :: String   -> D3Selection -> D3Selection
foreign import d3Exit_               :: D3Selection -> D3Selection
foreign import d3Data_               :: D3Data   -> D3Selection -> D3Selection
foreign import d3DataKeyFn_          :: D3Data   -> KeyFunction -> D3Selection -> D3Selection
foreign import d3RemoveSelection_    :: D3Selection -> D3Selection

-- NB D3 returns the selection after setting an Attr but we will only capture Selections that are 
-- meaningfully different _as_ selections, we're not chaining them in the same way
-- foreign import d3GetAttr_ :: String -> D3Selection -> ???? -- solve the ???? as needed later
foreign import d3AddTransition :: D3Selection -> Transition -> D3Selection -- this is the PS transition record
foreign import d3SetAttr_      :: String -> D3Attr -> D3Selection -> D3Selection
foreign import d3SetText_      :: D3Attr -> D3Selection -> D3Selection

foreign import emptyD3Selection :: D3Selection -- probably just null
foreign import emptyD3Data :: D3Data -- probably just null
data D3State = D3State D3Data D3Selection

makeD3State' :: forall a. a -> D3State
makeD3State' d = D3State (coerceD3Data d) emptyD3Selection

makeD3State :: forall a. a -> D3Selection -> D3State
makeD3State d selection = D3State (coerceD3Data d) selection

setData :: D3Data -> D3State -> D3State
setData d' (D3State d s) = (D3State d' s)

-- setSelection :: D3Selection -> D3State -> D3State
-- setSelection s' (D3State d s) = (D3State d s')

emptyD3State :: D3State
emptyD3State = D3State emptyD3Data emptyD3Selection

coerceD3Data :: forall a. a -> D3Data
coerceD3Data = unsafeCoerce

data D3_Node = D3_Node Element (Array Chainable)

-- sugar for appending with no attributes
node_ :: Element -> D3_Node
node_ = \e -> D3_Node e []

-- Transition types
type EasingTime = Number
type D3EasingFn = EasingTime -> EasingTime -- easing function maps 0-1 to 0-1 in some way with 0 -> 0, 1 -> 1
data EasingFunction = 
    DefaultCubic
  | EasingFunction D3EasingFn
  | EasingFactory (Datum -> Int -> D3Group -> D3This -> D3EasingFn)

type Transition = { name     :: String
                  , delay    :: Milliseconds-- can also be a function, ie (\d -> f d)
                  , duration :: Milliseconds -- can also be a function, ie (\d -> f d)
                  , easing   :: EasingFunction
}

data Chainable =  AttrT Attribute
                | TextT (Attrib String)
                | TransitionT Transition
                
type EnterUpdateExit = {
    enter  :: Array Chainable
  , update :: Array Chainable
  , exit   :: Array Chainable
}

