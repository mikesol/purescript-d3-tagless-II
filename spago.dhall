{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "affjax"
  , "argonaut"
  , "argonaut-codecs"
  , "argonaut-core"
  , "arrays"
  , "avar"
  , "bifunctors"
  , "bigints"
  , "console"
  , "const"
  , "control"
  , "datetime"
  , "debug"
  , "dom-indexed"
  , "effect"
  , "either"
  , "enums"
  , "exceptions"
  , "foldable-traversable"
  , "foreign-object"
  , "formatters"
  , "functions"
  , "fuzzy"
  , "graphs"
  , "halogen"
  , "halogen-renderless"
  , "halogen-select"
  , "halogen-subscriptions"
  , "halogen-svg-elems"
  , "halogen-vdom"
  , "html-parser-halogen"
  , "integers"
  , "js-timers"
  , "lists"
  , "math"
  , "maybe"
  , "media-types"
  , "newtype"
  , "now"
  , "nullable"
  , "numbers"
  , "ordered-collections"
  , "parallel"
  , "partial"
  , "prelude"
  , "profunctor"
  , "profunctor-lenses"
  , "psci-support"
  , "random"
  , "rationals"
  , "read"
  , "remotedata"
  , "strings"
  , "svg-parser-halogen"
  , "tailrec"
  , "transformers"
  , "tuples"
  , "typelevel-prelude"
  , "unfoldable"
  , "unsafe-coerce"
  , "variant"
  , "web-dom"
  , "web-events"
  , "web-file"
  , "web-html"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
