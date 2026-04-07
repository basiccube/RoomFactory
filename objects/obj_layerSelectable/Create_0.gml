layerName = layer_get_name(layer)
layerInfo = config_get_layer(layerName)

canResize = true

onPositionUpdate = func_empty
onScaleUpdate = func_empty

onDragStart = func_empty
onDragEnd = func_empty

onResizeStart = func_empty
onResizeEnd = func_empty

onDraw = draw_self