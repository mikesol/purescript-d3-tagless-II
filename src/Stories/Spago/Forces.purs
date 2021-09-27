module Stories.Spago.Forces where

import Prelude

import D3.Attributes.Instances (Label)
import D3.Data.Types (Datum_, Index_, PointXY, index_ToInt)
import D3.Examples.Spago.Model (datum_, numberToGridPoint, offsetXY, scalePoint)
import D3.Simulation.Config as F
import D3.Simulation.Forces (createForce, createLinkForce, initialize)
import D3.Simulation.Types (FixForceType(..), Force, ForceFilter(..), ForceStatus, ForceType(..), RegularForceType(..), _name, _status, allNodes)
import Data.Int (toNumber)
import Data.Lens (view)
import Data.Map (Map, fromFoldable)
import Data.Maybe (Maybe(..))
import Data.Number (infinity)
import Data.Tuple (Tuple(..))
import Debug (spy)

-- | table of all the forces that are used in the Spago component
forceLibrary :: Map Label Force
forceLibrary = initialize [
        createForce "center"       (RegularForce ForceCenter)   allNodes [ F.strength 0.5, F.x 0.0, F.y 0.0 ]
      , createForce "x"            (RegularForce ForceX)        allNodes [ F.strength 0.05, F.x 0.0 ]
      , createForce "y"            (RegularForce ForceY)        allNodes [ F.strength 0.07, F.y 0.0 ]

      , createForce "collide1"     (RegularForce ForceCollide)  allNodes [ F.strength 1.0, F.radius datum_.collideRadius ]
      , createForce "collide2"     (RegularForce ForceCollide)  allNodes [ F.strength 0.7, F.radius datum_.collideRadiusBig ]
      , createForce "charge1"      (RegularForce ForceManyBody) allNodes [ F.strength (-30.0), F.theta 0.9, F.distanceMin 1.0, F.distanceMax infinity ]
      , createForce "charge2"      (RegularForce ForceManyBody) allNodes [ F.strength (-100.0), F.theta 0.9, F.distanceMin 1.0, F.distanceMax 400.0 ]

      , createForce "clusterx"     (RegularForce ForceX)        modulesOnly [ F.strength 0.2, F.x datum_.gridPointX ]
      , createForce "clustery"     (RegularForce ForceY)        modulesOnly [ F.strength 0.2, F.y datum_.gridPointY ]

      , createForce "packageGrid"     (FixForce $ ForceFixPositionXY useGridXY) (Just $ ForceFilter "packages only" datum_.isPackage)           [ ] 
      , createForce "centerNamedNode" (FixForce $ ForceFixPositionXY centerXY) (Just $ ForceFilter "src only"     \d -> datum_.name d == "my-project") [ ] 
      , createForce "treeNodesPinned" (FixForce $ ForceFixPositionXY treeXY)   (Just $ ForceFilter "tree only"    \d -> datum_.connected d)     [ ] 
      
      , createForce "treeNodesX"  (RegularForce ForceX)  (Just $ ForceFilter "tree only" \d -> datum_.connected d)
          [ F.strength 0.2, F.x datum_.treePointX ] 
      , createForce "treeNodesY"  (RegularForce ForceY)  (Just $ ForceFilter "tree only" \d -> datum_.connected d)
          [ F.strength 0.2, F.y datum_.treePointY ] 

      , createForce "packageOrbit" (RegularForce ForceRadial)   packagesOnly 
                                   [ F.strength 0.8, F.x 0.0, F.y 0.0, F.radius 300.0 ]
      , createForce "unusedOrbit" (RegularForce ForceRadial)   unusedModulesOnly 
                                   [ F.strength 0.8, F.x 0.0, F.y 0.0, F.radius 900.0 ]
      , createForce "moduleOrbit" (RegularForce ForceRadial)   usedModulesOnly
                                   [ F.strength 0.8, F.x 0.0, F.y 0.0, F.radius 600.0 ]
                                   
      , createLinkForce Nothing [ F.strength 1.0, F.distance 0.0, F.numKey (toNumber <<< datum_.id) ]
      ]
  where
    packagesOnly      = Just $ ForceFilter "all packages" datum_.isPackage
    modulesOnly       = Just $ ForceFilter "all modules" datum_.isModule
    unusedModulesOnly = Just $ ForceFilter "unused modules only" datum_.isUnusedModule
    usedModulesOnly   = Just $ ForceFilter "used modules only" datum_.isUsedModule

    useGridXY d _ = datum_.gridPoint d
    centerXY _ _ = { x: 0.0, y: 0.0 }
    treeXY   d _ = spy "treePoint" $ datum_.treePoint d

-- | NOTES

-- gridForceSettings :: Array String
-- gridForceSettings = [ "packageGrid", "clusterx", "clustery", "collide1" ]

-- gridForceSettings2 :: Array String
-- gridForceSettings2 = [ "center", "collide2", "x", "y" ]

-- packageForceSettings :: Array String
-- packageForceSettings = [ "centerNamedNode", "center", "collide2", "charge2", "links"]

-- treeForceSettings :: Array String
-- treeForceSettings = ["links", "center", "charge1", "collide1" ]

-- these are the force settings for the force-layout radial tree in Observables
-- .force("link", d3.forceLink(links).id(d => d.id).distance(0).strength(1))
-- .force("charge", d3.forceManyBody().strength(-50))
-- .force("x", d3.forceX())
-- .force("y", d3.forceY());

