module D3Tagless.Instance.Selection where


import Control.Monad.State (class MonadState, StateT, runStateT)
import D3.Data.Types (D3Selection_)
import D3.FFI (d3Append_, d3AttachZoomDefaultExtent_, d3AttachZoom_, d3Data_, d3EnterAndAppend_, d3Exit_, d3FilterSelection_, d3KeyFunction_, d3SelectAllInDOM_, d3SelectionSelectAll_, defaultDrag_, disableDrag_)
import D3.Selection (Behavior(..), D3_Node(..), DragBehavior(..), Join(..), Keys(..), applyChainableSD3)
import D3.Zoom (ScaleExtent(..), ZoomExtent(..))
import D3Tagless.Capabilities (class SelectionM, modifySelection)
import Data.Foldable (foldl)
import Data.Tuple (Tuple, fst, snd)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Prelude (class Applicative, class Apply, class Bind, class Functor, class Monad, Unit, discard, liftA1, pure, show, unit, ($))

-- not actually using Effect in foreign fns to keep sigs simple (for now)

-- newtype D3M :: forall k. k -> Type -> Type
newtype D3M :: forall k. Type -> k -> Type -> Type
newtype D3M state selection a = D3M (StateT state Effect a) 

derive newtype instance functorD3M     :: Functor           (D3M state selection)
derive newtype instance applyD3M       :: Apply             (D3M state selection)
derive newtype instance applicativeD3M :: Applicative       (D3M state selection)
derive newtype instance bindD3M        :: Bind              (D3M state selection)
derive newtype instance monadD3M       :: Monad             (D3M state selection)
derive newtype instance monadStateD3M  :: MonadState  state (D3M state selection) 
derive newtype instance monadEffD3M    :: MonadEffect       (D3M state selection)


runD3M :: forall a. D3M Unit D3Selection_ a -> Effect (Tuple a Unit)
runD3M (D3M state_T) = runStateT state_T unit

eval_D3M :: forall a. D3M Unit D3Selection_ a -> Effect a
eval_D3M (D3M state_T) = liftA1 fst $ runStateT state_T unit

exec_D3M :: forall a. D3M Unit D3Selection_ a -> Effect Unit
exec_D3M (D3M state_T) = liftA1 snd $ runStateT state_T unit

-- | ====================================================
-- | Selection instance (capability) for the D3 interpreter
-- | ====================================================
instance d3TaglessD3M :: SelectionM D3Selection_ (D3M state D3Selection_) where
  attach selector = pure $ d3SelectAllInDOM_ selector 

  appendElement selection_ (D3_Node element attributes) = do
    let appended_ = d3Append_ (show element) selection_
    modifySelection appended_ attributes -- this modify is NOT stateT modify
    pure appended_

  filterSelection selection_ selector = pure $ d3FilterSelection_ selection_ selector

  modifySelection selection_ attributes = do
    let _ = foldl applyChainableSD3 selection_ attributes
    pure unit

  join selection (Join j) = do
    let 
      selectS = d3SelectionSelectAll_ (show j.element) selection
      dataS   = case j.key of
                  UseDatumAsKey    -> d3Data_        j.data    selectS 
                  (ComputeKey fn)  -> d3KeyFunction_ j.data fn selectS 
      enterS  = d3EnterAndAppend_ (show j.element) dataS
      enterS' = foldl applyChainableSD3 enterS j.behaviour
    pure enterS'

  join selection (JoinGeneral j) = do
    let
      selectS = d3SelectionSelectAll_ (show j.element) selection
      dataS  = case j.key of
                UseDatumAsKey    -> d3Data_        j.data    selectS 
                (ComputeKey fn)  -> d3KeyFunction_ j.data fn selectS 
      enterS = d3EnterAndAppend_ (show j.element) dataS
      exitS  = d3Exit_ dataS
      _      = foldl applyChainableSD3 enterS  j.behaviour.enter
      _      = foldl applyChainableSD3 exitS   j.behaviour.exit
      _      = foldl applyChainableSD3 dataS   j.behaviour.update
    pure enterS
  
  on selection (Drag drag) = do
    let _ = case drag of 
              DefaultDrag     -> defaultDrag_ selection 
              NoDrag          -> disableDrag_ selection
              (CustomDrag fn) -> defaultDrag_ selection -- TODO no custom drag implemented yet
    pure unit

  on selection (Zoom config) = do
    let 
      (ScaleExtent smallest largest) = config.scale
      target = selection
      -- TODO recover the ability to "direct" the zoom to element other than the one receiving the event
      -- ie for controllers, containers etc

    -- sticking to the rules of no ADT's on the JS side we case on the ZoomExtent here
      _ = case config.extent of
            DefaultZoomExtent -> 
              d3AttachZoomDefaultExtent_ selection {
                scaleExtent: [ smallest, largest ]
              , name  : config.name
              , target
              } 

            (ZoomExtent ze)   -> do
              d3AttachZoom_ selection { 
                extent     : [ [ ze.left, ze.top ], [ ze.right, ze.bottom ] ]
              , scaleExtent: [ smallest, largest ]
              , name  : config.name
              , target
              }
    pure unit