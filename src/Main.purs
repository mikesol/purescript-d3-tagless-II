module Main where

import Prelude

import D3.Examples.Simulation.LesMiserables as Graph
import D3.Examples.GUP (runGeneralUpdatePattern) as GUP
import D3.Examples.Tree.Configure as Tree
import D3.Layouts.Hierarchical (TreeJson_, getTreeViaAJAX, makeModel)
import D3.Layouts.Hierarchical.Types (TreeLayout(..), TreeType(..))
import Data.Bifunctor (rmap)
import Data.Foldable (sequence_)
import Effect (Effect)
import Effect.Aff (Aff, forkAff, launchAff_)

drawMetaTree :: TreeJson_ -> Aff Unit
drawMetaTree json =
  Tree.drawTree =<< makeModel TidyTree Vertical =<< Tree.getMetaTreeJSON =<< makeModel TidyTree Radial json

main :: Effect Unit
main = launchAff_  do
  _        <- forkAff GUP.runGeneralUpdatePattern
  _        <- forkAff Graph.drawGraph

  -- fetch an example model for the tree examples, the canonical flare dependency json in this case
  treeJSON <- getTreeViaAJAX "http://localhost:1234/flare-2.json"

  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel Dendrogram Horizontal json) treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel Dendrogram Vertical json)   treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel Dendrogram Radial json)     treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel TidyTree Horizontal json)   treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel TidyTree Vertical json)     treeJSON
  sequence_ $ rmap (\json -> Tree.drawTree =<< makeModel TidyTree Radial json)       treeJSON

  -- extract the structure of the radial tree "D3 script" and draw a radial tree of this "meta" tree
  -- sequence_ $ rmap drawMetaTree treeJSON

  pure unit
