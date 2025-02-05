module D3.Layouts.Hierarchical where

import D3.Node

import Affjax (Error, URL)
import Affjax as AJAX
import Affjax.ResponseFormat as ResponseFormat
import D3.Attributes.Instances (AttributeSetter(..), toAttr)
import D3.Data.Tree (TreeJson_, TreeLayout, TreeModel, TreeType)
import D3.Data.Types (Datum_)
import D3.FFI (find_, getLayout, hNodeDepth_, linkClusterHorizontal_, linkClusterVertical_, linkHorizontal2_, linkHorizontal_, linkRadial_, linkVertical_, sharesParent_)
import D3.Selection (SelectionAttribute(..))
import Data.Bifunctor (rmap)
import Data.Either (Either)
import Data.Function.Uncurried (Fn2, mkFn2)
import Data.Maybe (Maybe)
import Data.Nullable (toMaybe)
import Effect.Aff (Aff)
import Effect.Class (class MonadEffect)
import Prelude (class Bind, bind, pure, ($), (/))

find :: forall d. D3_TreeNode d -> (Datum_ -> Boolean) -> Maybe (D3_TreeNode d)
find tree filter = toMaybe $ find_ tree filter

getTreeViaAJAX :: URL -> Aff (Either Error TreeJson_)
getTreeViaAJAX url = do
  result <- AJAX.get ResponseFormat.string url
  pure $ rmap (\{body} -> readJSON_ body) result  

makeModel :: Bind Aff => 
  MonadEffect Aff => 
  TreeType -> 
  TreeLayout ->
  TreeJson_ -> 
  Aff TreeModel
makeModel treeType treeLayout json = do
  let 
    -- svgConfig  = { width: fst widthHeight, height: snd widthHeight }
    treeLayoutFn = getLayout treeType -- REVIEW why not run this here and fill in root_ ?
    svgConfig    = { width: 650.0, height: 650.0 }
  pure $ { json, treeType, treeLayout, treeLayoutFn, svgConfig }

foreign import readJSON_                :: String -> TreeJson_ -- TODO no error handling at all here RN

-- not clear if we really want to write all these in PureScript, there is no Eq instance for parents etc
-- but it will at least serve as documentation
-- OTOH if it can be nicely written here, so much the better as custom separation and all _is_ necessary
defaultSeparation :: forall d. Fn2 (D3_TreeNode d) (D3_TreeNode d) Number
defaultSeparation = mkFn2 (\a b -> if (sharesParent_ a b) 
                                   then 1.0
                                   else 2.0)

radialSeparation :: forall r. Fn2 (D3_TreeNode r) (D3_TreeNode r) Number 
radialSeparation  = mkFn2 (\a b -> if (sharesParent_ a b) 
                                   then 1.0 
                                   else 2.0 / (hNodeDepth_ a))

horizontalLink :: SelectionAttribute
horizontalLink = AttrT $ AttributeSetter "d" $ toAttr linkHorizontal_

-- version for when the x and y point are already swapped
-- should be default someday
horizontalLink' :: SelectionAttribute
horizontalLink' = AttrT $ AttributeSetter "d" $ toAttr linkHorizontal2_

verticalLink :: SelectionAttribute
verticalLink = AttrT $ AttributeSetter "d" $ toAttr linkVertical_

horizontalClusterLink :: Number -> SelectionAttribute
horizontalClusterLink yOffset = AttrT $ AttributeSetter "d" $ toAttr (linkClusterHorizontal_ yOffset)

verticalClusterLink :: Number -> SelectionAttribute
verticalClusterLink xOffset = AttrT $ AttributeSetter "d" $ toAttr (linkClusterVertical_ xOffset)

radialLink :: (Datum_ -> Number) -> (Datum_ -> Number) -> SelectionAttribute
radialLink angleFn radius_Fn = do
  let radialFn = linkRadial_ angleFn radius_Fn
  AttrT $ AttributeSetter "d" $ toAttr radialFn



