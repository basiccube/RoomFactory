function ui_mainmenubar()
{
	ImGui.BeginMainMenuBar()
	
	if ImGui.BeginMenu("File")
	{
		if ImGui.MenuItem("New")
			clear_room()
		ImGui.Separator()
		
		if ImGui.MenuItem("Open")
		{
			var p = get_open_filename(ROOM_FILTER, "")
			if (p != "")
				load_room(p)
		}
		ImGui.Separator()
		
		if ImGui.MenuItem("Save")
			save_room(global.roomPath)
		if ImGui.MenuItem("Save As...")
			save_room()
		
		ImGui.Separator()
		if ImGui.MenuItem("Quit")
			game_end()
			
		ImGui.EndMenu()
	}
	
	if ImGui.BeginMenu("Help")
	{
		if ImGui.MenuItem("Demo Window", undefined, showDemoWindow)
			showDemoWindow = !showDemoWindow
		if ImGui.MenuItem("About ImGui...", undefined, showImGuiAboutWindow)
			showImGuiAboutWindow = !showImGuiAboutWindow
		
		ImGui.Separator()
		if ImGui.MenuItem("About Room Factory...", undefined, showAboutWindow)
			showAboutWindow = !showAboutWindow
		
		ImGui.EndMenu()
	}
	
	ImGui.EndMainMenuBar()
}

function ui_aboutwindow()
{
	if !showAboutWindow
		exit;
	
	ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Appearing, 0.5, 0.5)
	
	var show = ImGui.Begin("About Room Factory", showAboutWindow, ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoCollapse, ImGuiReturnMask.Both)
	showAboutWindow = show & ImGuiReturnMask.Pointer
	
	if (show & ImGuiReturnMask.Return)
	{
		ImGui.Text("Room Factory")
		ImGui.Text("A room editor for GameMaker games")
		
		ImGui.Separator()
		ImGui.Text(concat("Version ", GM_version))
		
		if ImGui.Button("OK", 64, 24)
			showAboutWindow = false
	}
	
	ImGui.End()
}

#macro OBJECTPICKER_MAX_ROW 6

function ui_objectpicker()
{
	if !config_loaded()
		exit;
	if instance_exists(obj_objectPlacer)
		exit;
	
	ImGui.SetNextWindowPos(10, 32, ImGuiCond.Always)
	var window_flags = ImGuiWindowFlags.NoDecoration |
					ImGuiWindowFlags.AlwaysAutoResize |
					ImGuiWindowFlags.NoSavedSettings |
					ImGuiWindowFlags.NoFocusOnAppearing |
					ImGuiWindowFlags.NoNav
	
	if ImGui.Begin("Object Picker", true, window_flags)
	{
		ImGui.Text("Object Picker")
		ImGui.Separator()
	
		var objects = config_get_objects()
		for (var i = 0, n = array_length(objects); i < n; i++)
		{
			var cat = objects[i]
			ImGui.Text(cat.name)
			ImGui.Separator()
			
			for (var j = 0, m = array_length(cat.objects); j < m; j++)
			{
				var obj = cat.objects[j]
				var spr = config_get_objectdata_sprite(obj)
				if (spr != undefined)
				{
					if (j > 0 && (j % OBJECTPICKER_MAX_ROW) != 0)
						ImGui.SameLine()
					
					if ImGui.ImageButton(obj.name, spr, 0, c_white, 1, c_white, 0)
					{
						with (instance_create_depth(mouse_x, mouse_y, -10, obj_objectPlacer))
						{
							objectData = obj
							layerName = other.currentLayer
						}
					}
					
					if ImGui.IsItemHovered(ImGuiHoveredFlags.ForTooltip)
						ImGui.SetTooltip(obj.name)
				}
			}
		}
	
		ImGui.End()
	}
}

function ui_layerlist()
{
	if !config_loaded()
		exit;
	if instance_exists(obj_objectPlacer)
		exit;
	
	ImGui.SetNextWindowPos(10, room_height - 8, ImGuiCond.Always, 0, 1)
	var window_flags = ImGuiWindowFlags.NoDecoration |
					ImGuiWindowFlags.AlwaysAutoResize |
					ImGuiWindowFlags.NoSavedSettings |
					ImGuiWindowFlags.NoFocusOnAppearing |
					ImGuiWindowFlags.NoNav
	
	if ImGui.Begin("Layer List", true, window_flags)
	{
		ImGui.Text("Layer List")
		ImGui.Separator()
		ImGui.Text(concat("Current layer: ", config_get_current_layer().displayName))
		
		var arr = config_get_layers()
		if ImGui.BeginListBox("##Layer Listbox", 192)
		{
			for (var i = 0, n = array_length(arr); i < n; i++)
			{
				var selected = (arr[i].name == currentLayer)
				if ImGui.Selectable(arr[i].displayName, selected)
				{
					selectedObject = undefined
					currentLayer = arr[i].name
				}
					
				if selected
					ImGui.SetItemDefaultFocus()
			}
			ImGui.EndListBox()
		}
		
		ImGui.End()
	}
}

function update_titlebar()
{
	var rftitle = "Room Factory"
	var str = rftitle
	if (is_undefined(global.roomPath) || global.roomPath == "")
		str = concat("[Untitled] - ", rftitle)
	else
		str = concat("[", filename_name(global.roomPath), "] - ", rftitle)
		
	window_set_caption(str)
}