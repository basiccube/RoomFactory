#macro BUTTON_WIDTH (80 * settings.scale)
#macro BUTTON_HEIGHT (24 * settings.scale)

function ui_aboutwindow()
{
	if !showAboutWindow
		exit;
	
	ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Appearing, 0.5, 0.5)
	
	var show = ImGui.Begin("About Room Factory", showAboutWindow, ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.NoDocking, ImGuiReturnMask.Both)
	showAboutWindow = show & ImGuiReturnMask.Pointer
	
	if (show & ImGuiReturnMask.Return)
	{
		ImGui.Text("Room Factory")
		ImGui.Text("A room editor for GameMaker games")
		
		ImGui.Separator()
		ImGui.Text($"Version {GM_version}")
		ImGui.TextLinkOpenURL("GitHub", "https://github.com/basiccube/RoomFactory")
		
		ImGui.SameLine(0, 128 * settings.scale)
		if ImGui.Button("OK", BUTTON_WIDTH, BUTTON_HEIGHT)
			showAboutWindow = false
	}
	
	ImGui.End()
}

#macro GRIDSIZE_BUTTON_SIZE (22 * settings.scale)

function ui_gridsize()
{
	if !windows.gridsize
		exit;
	
	ImGui.SetNextWindowPos(room_width - 10, room_height - 8, ImGuiCond.Always, 1, 1)
	var window_flags = ImGuiWindowFlags.NoDecoration |
					ImGuiWindowFlags.AlwaysAutoResize |
					ImGuiWindowFlags.NoSavedSettings |
					ImGuiWindowFlags.NoFocusOnAppearing |
					ImGuiWindowFlags.NoNav
					
	if ImGui.Begin("Grid Size", true, window_flags)
	{
		snapToGrid = ImGui.Checkbox("##snapToGrid", snapToGrid)
		ImGui.SameLine()
		
		ImGui.Text($"Grid Size: {gridSize}")
		
		ImGui.SameLine()
		if ImGui.Button("+", GRIDSIZE_BUTTON_SIZE, GRIDSIZE_BUTTON_SIZE)
			grid_increase()
		
		ImGui.SameLine()
		if ImGui.Button("-", GRIDSIZE_BUTTON_SIZE, GRIDSIZE_BUTTON_SIZE)
			grid_decrease()
			
		ImGui.SameLine()
		if ImGui.Button("/", GRIDSIZE_BUTTON_SIZE, GRIDSIZE_BUTTON_SIZE)
		{
			gridSize = 16
			if struct_exists(global.config.roomDefaults, "gridSize")
				gridSize = global.config.roomDefaults.gridSize
		}
		
		ImGui.End()
	}
}

function ui_layerlist()
{
	if !windows.layerlist
		exit;
	
	if !config_loaded()
		exit;
	if instance_exists(obj_placer)
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
		
		if (obj_roomManager.roomFormat == ROOMFORMAT_CYOP)
		{
			var updateLayer = false
			ImGui.Text($"Instance layer {currentCYOPLayer}")
			
			ImGui.SameLine()
			if ImGui.ArrowButton("##CYOPLayerLeft", 0)
			{
				currentCYOPLayer--
				updateLayer = true
			}
			
			ImGui.SameLine()
			if ImGui.ArrowButton("##CYOPLayerRight", 1)
			{
				currentCYOPLayer++
				updateLayer = true
			}
			
			currentCYOPLayer = clamp(currentCYOPLayer, 0, CYOP_INSTANCE_MAX_LAYERS)
			if updateLayer
			{
				setCurrentLayer($"{CYOP_INSTANCE_LAYER_PREFIX}{currentCYOPLayer}")
				selectionArray = []
				deselectObject()
			}
		}
		else
		{
			ImGui.Text($"Current layer: {config_get_current_layer().displayName}")
			
			static layerArray = config_get_layers()
			static layerStruct = undefined
			static layerTypes = []
			if is_undefined(layerStruct)
			{
				layerStruct = {}
				for (var i = 0, n = array_length(layerArray); i < n; i++)
				{
					var lay = layerArray[i]
					var type = lay.type
					
					// Replace the first character to be uppercase
					var char = string_upper(string_char_at(type, 1))
					type = string_insert(char, string_delete(type, 1, 1), 1)
					
					if !struct_exists(layerStruct, type)
					{
						layerStruct[$ type] = []
						
						// Make instances the first tab
						if (string_char_at(type, 1) == "I")
							array_insert(layerTypes, 0, type)
						else
							array_push(layerTypes, type)
					}
					
					array_push(layerStruct[$ type], lay)
				}
			}
			
			if ImGui.BeginTabBar("##LayerTabbar", ImGuiTabBarFlags.TabListPopupButton | ImGuiTabBarFlags.FittingPolicyScroll)
			{
				for (var i = 0, n = array_length(layerTypes); i < n; i++)
				{
					var arr = layerStruct[$ layerTypes[i]]
					if ImGui.BeginTabItem(layerTypes[i])
					{
						if ImGui.BeginListBox($"##{layerTypes[i]}ListBox", 220 * settings.scale, 160 * settings.scale)
						{
							for (var j = 0, m = array_length(arr); j < m; j++)
							{
								if layer_exists(arr[j].name)
								{
									var layVisible = layer_get_visible(arr[j].name)
									var newVisible = ImGui.Checkbox("##visible" + arr[j].displayName, layVisible)
									if (newVisible != layVisible)
										layer_set_visible(arr[j].name, newVisible)
						
									ImGui.SameLine()
								}
								
								var selected = (arr[j].name == currentLayer)
								if ImGui.Selectable(arr[j].displayName, selected)
								{
									setCurrentLayer(arr[j].name)
									selectionArray = []
									deselectObject()
								}
					
								if selected
									ImGui.SetItemDefaultFocus()
							}
							
							ImGui.EndListBox()
						}
						
						ImGui.EndTabItem()
					}
				}
				
				ImGui.EndTabBar()
			}
		}
		
		ImGui.End()
	}
}

function ui_configpicker()
{
	if !showConfigPicker
		exit;
	
	ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Always, 0.5, 0.5)
	
	var show = ImGui.Begin("Welcome to Room Factory", showConfigPicker, ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.NoSavedSettings | ImGuiWindowFlags.NoCollapse, ImGuiReturnMask.Both)
	showConfigPicker = show & ImGuiReturnMask.Pointer
	
	if (show & ImGuiReturnMask.Return)
	{
		ImGui.Text($"Welcome to Room Factory version {GM_version}")
		ImGui.Separator()
		
		ImGui.Text("Select a game configuration:")
		
		static searched = false
		static searcharr = []
		static selection = 0
		
		if !searched
		{
			var file = file_find_first($"{CONFIG_PATH}*.rfcfg", fa_none)
			while (file != "")
			{
				var jfile = file_text_read_all($"{CONFIG_PATH}{file}")
				var json = json_parse(jfile)
				
				array_push(searcharr, [file, json.name])
				file = file_find_next()
			}
			
			searched = true
		}
		
		if ImGui.BeginListBox("##Config Listbox", 300 * settings.scale, 260 * settings.scale)
		{
			for (var i = 0, n = array_length(searcharr); i < n; i++)
			{
				var conf = searcharr[i]
				var selected = (selection == i)
				
				if ImGui.Selectable(conf[1], selected)
					selection = i
					
				if selected
					ImGui.SetItemDefaultFocus()
			}
			ImGui.EndListBox()
		}
		
		var disabled = (array_length(searcharr) <= 0)
		if disabled
			ImGui.BeginDisabled()
		
		if ImGui.Button("OK", BUTTON_WIDTH, BUTTON_HEIGHT)
		{
			if config_load(searcharr[selection][0])
			{
				clear_room()
				showConfigPicker = false
			}
		}
		
		if disabled
			ImGui.EndDisabled()
		
		ImGui.SameLine()
		if ImGui.Button("Quit", BUTTON_WIDTH, BUTTON_HEIGHT)
			game_end(0)
	}
	
	ImGui.End()
}