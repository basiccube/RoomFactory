if (sprite_index != undefined)
{
	var prevBlend = image_blend
	if (obj_mainUI.viewOptions.darkenLayers && layer != obj_mainUI.currentLayerID)
		image_blend = c_gray
	
	onDraw()
	image_blend = prevBlend
	
	if obj_mainUI.viewOptions.showLayerNames
		draw_ui_text(bbox_left, bbox_top, layerInfo.displayName, smallFont)
}