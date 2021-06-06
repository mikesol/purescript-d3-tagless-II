module Main where

import Prelude

import D3.Data.Tree (TreeJson_, TreeLayout(..), TreeType(..))
import D3.Examples.MetaTree as MetaTree
import D3.Examples.Tree.Configure as Tree
import D3.Layouts.Hierarchical (makeModel)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(Tuple))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Foreign.Object as Object
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.Storybook (Stories, runStorybook, proxy)
import Stories.Count as ExpCount
import Stories.GUP as D3GUP
import Stories.Index as ExpIndex
import Stories.LesMis as LesMis
import Stories.MetaTree as MetaTree
import Stories.PrintTree as PrintTree
import Stories.Trees as Trees

drawMetaTree :: TreeJson_ -> Aff Unit
drawMetaTree json =
  MetaTree.drawTree =<< makeModel TidyTree Vertical =<< Tree.getMetaTreeJSON =<< makeModel TidyTree Radial json

ddi :: Aff Unit
ddi = do
{-
  treeJSON <- getTreeViaAJAX "http://localhost:1234/flare-2.json"
  _        <- forkAff Spago.drawGraph
  
  _        <- forkAff LesMis.drawGraph


  -- fetch an example model for the tree examples, the canonical flare dependency json in this case

  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel Dendrogram Horizontal json) treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel Dendrogram Vertical json)   treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel Dendrogram Radial json)     treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel TidyTree Horizontal json)   treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel TidyTree Vertical json)     treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel TidyTree Radial json)       treeJSON

  sequence_ $ rmap (\json -> Tree.printTree =<< makeModel TidyTree Radial json)       treeJSON

  -- extract the structure of the radial tree "D3 script" and draw a radial tree of this "meta" tree
  sequence_ $ rmap drawMetaTree treeJSON
-- -}

  pure unit


stories :: forall m. (MonadAff m) => Stories m
stories = Object.fromFoldable
  [ Tuple "" $ proxy ExpIndex.component
  , Tuple "GUP" $ proxy D3GUP.component
  , Tuple "LesMis" $ proxy LesMis.component
  , Tuple "Trees" $ proxy Trees.component
  , Tuple "Meta-Tree" $ proxy MetaTree.component
  , Tuple "Print-Tree" $ proxy PrintTree.component
  ]

logo :: HH.PlainHTML
logo = HH.text "Data Driven Interfaces in PureScript"

main :: Effect Unit
main = HA.runHalogenAff do
  HA.awaitBody >>= runStorybook
    { stories
    , logo: Just logo
    }
