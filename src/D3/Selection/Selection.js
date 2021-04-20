exports.emptyD3Data_ = null

const debug = false;

// d3SelectAll_ :: Selector -> D3Selection
exports.d3SelectAllInDOM_ = selector => { // NB not USING selection but want it cause called from inside State Monad
  if (debug) { showSelectAllInDOM_(selector); }
  return d3.selectAll(selector);
} 
// d3SelectAll_ :: Selector -> D3Selection
exports.d3SelectionSelectAll_ = selector => selection => {
  if (debug) { showSelectionSelectAll_(selector)(selection); }
  return selection.selectAll(selector);
} 
// d3Enter_ :: D3Selection -> D3Selection
exports.d3EnterAndAppend_ = element => selection => {
  if (debug) { showEnterAndAppend_(element)(selection); }
  return selection.enter().append(element);
}
// d3Exit_ :: D3Selection -> D3Selection
exports.d3Exit_ = selection => {
  if (debug) { showExit_(selection); }
  return selection.exit();
}
// d3AddTransition :: D3Selection -> D3Selection
exports.d3AddTransition_ = selection => transition => {
  var handle; 
  if (debug) { showAddTransition_(selection)(transition); }
  if (transition.name == "") {
    handle = selection.transition();
    // if transition is unnamed we configure it...
    if (transition.duration != 0) {
      handle.duration(transition.duration);
    }
    if (transition.delay != 0) {
      handle.delay(transition.delay);
    }
  } else {
    handle = selection.transition(transition.name);
  }
  return handle; 
}

// d3RemoveSelection_ :: D3Selection -> D3Selection
exports.d3RemoveSelection_ = selection => {
  if (debug) { showRemoveSelection_(selection); }
  return selection.remove();
}
// d3Append_ :: String -> D3Selection -> D3Selection
exports.d3Append_ = element => selection => {
  if (debug) { showAppend_(element)(selection); }
  return selection.append(element);
}
// d3Data_ :: D3Data -> D3Selection -> D3Selection
exports.d3Data_ = data => selection => {
  if (debug) { showData_(data)(selection); }
  return selection.data(data, d => d );
}
// d3Data_ :: D3Data -> KeyFunction -> D3Selection -> D3Selection
exports.d3KeyFunction_ = data => keyFunction => selection => {
  if (debug) { showKeyFunction_(data)(keyFunction)(selection); }
  return selection.data(data, keyFunction);
}
// d3SetAttr_      :: String -> D3Attr -> D3Selection -> Unit 
exports.d3SetAttr_ = name => value => selection => {
  if (debug) { showSetAttr_(name)(value)(selection); }
  return selection.attr(name, value);
}
// d3SetAttr_      :: String -> D3Attr -> D3Selection -> Unit 
exports.d3SetText_ = value => selection => {
  if (debug) { showSetText_(value, selection); }
  return selection.text(value);
}

// foreign import attachZoom :: D3Selection_ -> ZoomConfigDefault_ -> D3Selection_
exports.d3AttachZoomDefaultExtent_ = selection => config => { 
  if (debug) { showAttachZoomDefaultExtent_(selection)(config); }
  function zoomed({transform}) {
    selection.attr("transform", transform);
  }
  // "If extent is not specified, returns the current extent accessor, which
  // defaults to [[0, 0], [width, height]] where width is the client width of the
  // element and height is its client height; for SVG elements, the nearest
  // ancestor SVG element’s viewBox, or width and height attributes, are used.""
  return selection.call(d3.zoom() 
                  .scaleExtent(config.scaleExtent)
                  .on(`zoom.${config.qualifier}`, zoomed));
                  // .on("zoom", zoomed));
                }
                
// foreign import attachZoom :: D3Selection_ -> ZoomConfig_ -> D3Selection_
exports.d3AttachZoom_ = selection => config => { 
  if (debug) { showAttachZoom_(selection)(config) }
  function zoomed({transform}) { // TODO try arrow function below instead
    selection.attr("transform", transform);
  }
  return selection.call(d3.zoom()
                          .extent(config.extent)
                          .scaleExtent(config.scaleExtent)
                          .on(`zoom.${config.qualifier}`, zoomed));
                          // .on("zoom", zoomed));
}

exports.showSelectAllInDOM_ = selector => {
  return (`\td3SelectAllInDOM: ${selector}`)
}
exports.showSelectAll_ = selector => selection => {
  return (`\td3SelectionSelectAll: ${selection}.selectAll(${selector})`)
}
exports.showEnterAndAppend_ = element => selection => {
  return (`\td3EnterAndAppend: ${selection}.enter().append(${element})`)
}
exports.showExit_ = selection => {
  return (`\td3Exit: ${selection}.exit()`)
}
exports.showAddTransition_ = selection => transition => {
  if (transition.name == "") {
    const statement1 = `\td3addTransition: ${selection}.transition(${transition})`;
    var statement2 = "";
    var statement3 = "";
    if (transition.duration != 0) {
      statement2 = `transition.duration(${transition.duration})`;
    }
    if (transition.delay != 0) {
      statement3 = `\t\ttransition.delay(${transition.delay})`;
    }
    return (statement1 + statement2 + statement3);
  } else {
    return(`\td3addNamedTransition: ${selection}.transition(${transition})`);
  }
}
exports.showRemoveSelection_ = selection => {
  return (`\td3Remove: ${selection}.remove()`)
}
exports.showAppend_ = element => selection => {
  return (`\td3Append: ${selection}.append(${element})`)
}
exports.showKeyFunction_ = data => keyFunction => selection => {
  return (`\td3Data: ${selection}.data(${data}, ${keyFunction})`)
}
exports.showData_ = data => selection => {
  return (`\td3Data: ${selection}.data(${data})`)
}
exports.showSetAttr_ = name => value => selection => {
  return (`\t${selection}.attr(${name}, ${value})`);
}
exports.showSetText_ = value => selection => {
  return (`\t${selection}.text(${value})`)
}
exports.showAttachZoomDefaultExtent_ = selection => config => {
  return (`\t${selection}.call(zoom ${config})`)
}
exports.showAttachZoom_ = selection => config => {
  return (`\t${selection}.call(zoom ${config})`)
}