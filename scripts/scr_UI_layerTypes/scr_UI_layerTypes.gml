#macro LAYERTYPES_WINDOW_FLAGS	ImGuiWindowFlags.NoDecoration |			\
								ImGuiWindowFlags.AlwaysAutoResize |		\
								ImGuiWindowFlags.NoSavedSettings |		\
								ImGuiWindowFlags.NoFocusOnAppearing |	\
								ImGuiWindowFlags.NoNav

#macro LAYERTYPES_WINDOW_X 10
#macro LAYERTYPES_WINDOW_Y 32

#macro LAYERTYPES_WINDOW_WIDTH (256 * settings.scale)
#macro LAYERTYPES_WINDOW_HEIGHT (340 * settings.scale)

#macro LAYERTYPES_LIST_WIDTH (LAYERTYPES_WINDOW_WIDTH - (settings.scale > 1 ? (8 * settings.scale) : 16))
#macro LAYERTYPES_LIST_HEIGHT (256 * settings.scale)

function ui_layertypes()
{
	if !windows.layertypes
		exit;
		
	if !config_loaded()
		exit;
	if instance_exists(obj_placer)
		exit;
	if (layer_exists(obj_mainUI.currentLayer) && !layer_get_visible(obj_mainUI.currentLayer))
		exit;
	
	var windowPosX = LAYERTYPES_WINDOW_X
	var windowPosY = LAYERTYPES_WINDOW_Y
	if (settings.scale > 1)
		windowPosY *= settings.scale / 1.5
	
	ImGui.SetNextWindowPos(windowPosX, windowPosY, ImGuiCond.Always)
	
	switch config_get_layer_type()
	{
		case CONFIG_LAYER_INSTANCE: ui_objectpicker(); break;
		case CONFIG_LAYER_ASSET: ui_assetsprites(); break;
	}
}

function ui_objectpicker()
{
	ImGui.SetNextWindowSizeConstraints(0, 0, LAYERTYPES_WINDOW_WIDTH, LAYERTYPES_WINDOW_HEIGHT)
	if ImGui.Begin("Object Picker", true, LAYERTYPES_WINDOW_FLAGS)
	{
		ImGui.Text("Object Picker")
		ImGui.Separator()
		
		if ImGui.BeginTabBar("Object Categories", ImGuiTabBarFlags.TabListPopupButton | ImGuiTabBarFlags.FittingPolicyScroll)
		{
			var objects = config_get_objects()
			for (var i = 0, n = array_length(objects); i < n; i++)
			{
				var cat = objects[i]
				if ImGui.BeginTabItem(cat.name)
				{
					if ImGui.BeginListBox($"## {cat.name} list", LAYERTYPES_LIST_WIDTH, LAYERTYPES_LIST_HEIGHT)
					{
						for (var j = 0, m = array_length(cat.objects); j < m; j++)
						{
							var obj = cat.objects[j]
							var scale = 32 * settings.scale
							
							var sy = ImGui.GetCursorScreenPosY()
							if (sy > 0 && sy < LAYERTYPES_WINDOW_Y + LAYERTYPES_WINDOW_HEIGHT)
							{
								var spr = config_get_object_sprite(obj)
								ImGui.Image(spr, 0, c_white, 1, scale, scale)
								ImGui.SameLine()
							}
							
							if ImGui.Selectable(obj.name, false, ImGuiSelectableFlags.None, 0, scale)
							{
								deselectObject()
								lastObject = obj
								with (instance_create_depth(mouse_x, mouse_y, -10, obj_placer))
								{
									objectData = obj
									layerName = other.currentLayer
									layerType = config_get_layer_type(other.currentLayer)
								}
							}
							
							if ImGui.IsItemHovered(ImGuiHoveredFlags.ForTooltip)
								ImGui.SetTooltip(obj.name)
						}
						ImGui.EndListBox()
					}
					
					ImGui.EndTabItem()
				}
			}
			
			ImGui.EndTabBar()
		}
	
		ImGui.End()
	}
}

function ui_assetsprites()
{
	ImGui.SetNextWindowSizeConstraints(0, 0, LAYERTYPES_WINDOW_WIDTH, LAYERTYPES_WINDOW_HEIGHT)
	if ImGui.Begin("Asset Sprite List", true, LAYERTYPES_WINDOW_FLAGS)
	{
		ImGui.Text("Asset Sprite List")
		ImGui.Separator()
		
		if ImGui.BeginTabBar("Sprite Categories", ImGuiTabBarFlags.TabListPopupButton | ImGuiTabBarFlags.FittingPolicyScroll)
		{
			var arr = ConfigAssetSprites.categories
			for (var i = 0, n = array_length(arr); i < n; i++)
			{
				var catName = arr[i]
				var cat = ds_map_find_value(ConfigAssetSprites.map, catName)
				if ImGui.BeginTabItem(catName)
				{
					if ImGui.BeginListBox($"## {catName} list", LAYERTYPES_LIST_WIDTH, LAYERTYPES_LIST_HEIGHT)
					{
						var names = struct_get_names(cat)
						array_sort(names, true)
						
						var func = method({ cat : cat, mainUI : id }, function(name, index)
						{
							var sprite = cat[$ name]
							var scale = 32 * settings.scale
							
							var sy = ImGui.GetCursorScreenPosY()
							if (sy > 0 && sy < LAYERTYPES_WINDOW_Y + LAYERTYPES_WINDOW_HEIGHT)
							{
								ImGui.Image(sprite.GetSprite(), 0, c_white, 1, scale, scale)
								ImGui.SameLine()
							}
							
							if ImGui.Selectable(name, false, ImGuiSelectableFlags.None, 0, scale)
							{
								mainUI.deselectObject()
								with (instance_create_depth(mouse_x, mouse_y, -10, obj_placer))
								{
									assetSprite = sprite
									layerName = other.mainUI.currentLayer
									layerType = config_get_layer_type(other.mainUI.currentLayer)
								}
							}
							
							if ImGui.IsItemHovered(ImGuiHoveredFlags.ForTooltip)
								ImGui.SetTooltip(name)
						})
						array_foreach(names, func)
						
						ImGui.EndListBox()
					}
					ImGui.EndTabItem()
				}
			}
			
			ImGui.EndTabBar()
		}
	
		ImGui.End()
	}
}