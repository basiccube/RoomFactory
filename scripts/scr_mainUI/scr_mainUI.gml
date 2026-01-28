#macro BUTTON_WIDTH 80
#macro BUTTON_HEIGHT 24

function menu_new()
{
	clear_room()
}

function menu_open()
{
	var filter = config_get_file_filter()
	var p = get_open_filename(filter[0], "")
	if (p != "")
	{
		load_room(p)
		recents_push(p)
	}
}

function menu_save()
{
	save_room(global.roomPath)
	recents_push(global.roomPath)
}

function menu_save_as()
{
	save_room()
	recents_push(global.roomPath)
}

function menu_handle_shortcuts()
{
	if !keyboard_check(vk_control)
		exit;
		
	// file menu
	if keyboard_check_pressed(ord("N"))
		menu_new()
	if keyboard_check_pressed(ord("O"))
		menu_open()
	if keyboard_check_pressed(ord("S"))
	{
		if keyboard_check(vk_shift)
			menu_save_as()
		else
			menu_save()
	}
}

function ui_mainmenubar()
{
	ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, 12, 6)
	ImGui.BeginMainMenuBar()
	
	if ImGui.BeginMenu("File")
	{
		if ImGui.MenuItem("New", "Ctrl+N")
			menu_new()
		ImGui.Separator()
		
		if ImGui.MenuItem("Open", "Ctrl+O")
			menu_open()
		
		if ImGui.BeginMenu("Recent")
		{
			for (var i = 0; i < MAX_RECENTS; i++)
			{
				var recent = global.recents[i]
				if is_undefined(recent)
					continue;
				
				if ImGui.MenuItem(recent)
				{
					load_room(recent)
					recents_push(recent)
				}
			}
			ImGui.EndMenu()
		}
		
		ImGui.Separator()
		
		if ImGui.MenuItem("Save", "Ctrl+S")
			menu_save()
		if ImGui.MenuItem("Save As...", "Ctrl+Shift+S")
			menu_save_as()
		
		ImGui.Separator()
		if ImGui.MenuItem("Quit")
			game_end()
			
		ImGui.EndMenu()
	}
	
	if ImGui.BeginMenu("Windows")
	{
		if ImGui.MenuItem("Object Picker", undefined, windows.objectpicker)
			windows.objectpicker = !windows.objectpicker
		if ImGui.MenuItem("Layer List", undefined, windows.layerlist)
			windows.layerlist = !windows.layerlist
		if ImGui.MenuItem("Inspector", undefined, windows.inspector)
			windows.inspector = !windows.inspector
		if ImGui.MenuItem("Grid Size", undefined, windows.gridsize)
			windows.gridsize = !windows.gridsize
		ImGui.EndMenu()
	}
	
	if ImGui.BeginMenu("Help")
	{
		if ImGui.MenuItem("ImGui Demo Window", undefined, showDemoWindow)
			showDemoWindow = !showDemoWindow
		if ImGui.MenuItem("About ImGui...")
			showImGuiAboutWindow = !showImGuiAboutWindow
		
		ImGui.Separator()
		if ImGui.MenuItem("About Room Factory...")
			showAboutWindow = !showAboutWindow
		
		ImGui.EndMenu()
	}
	
	ImGui.EndMainMenuBar()
	ImGui.PopStyleVar()
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
		
		if ImGui.Button("OK", BUTTON_WIDTH, BUTTON_HEIGHT)
			showAboutWindow = false
	}
	
	ImGui.End()
}

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
		ImGui.Text(concat("Grid Size: ", gridSize))
		
		ImGui.SameLine()
		if ImGui.Button("+", 20, 20)
			grid_increase()
		
		ImGui.SameLine()
		if ImGui.Button("-", 20, 20)
			grid_decrease()
			
		ImGui.SameLine()
		if ImGui.Button("/", 20, 20)
			gridSize = 16
		
		ImGui.End()
	}
}

function ui_objectpicker()
{
	if !windows.objectpicker
		exit;
	
	if !config_loaded()
		exit;
	if instance_exists(obj_objectPlacer)
		exit;
	if (layer_exists(obj_mainUI.currentLayer) && !layer_get_visible(obj_mainUI.currentLayer))
		exit;
	
	ImGui.SetNextWindowPos(10, 32, ImGuiCond.Always)
	ImGui.SetNextWindowSizeConstraints(0, 0, 256, 340)
	var window_flags = ImGuiWindowFlags.NoDecoration |
					ImGuiWindowFlags.AlwaysAutoResize |
					ImGuiWindowFlags.NoSavedSettings |
					ImGuiWindowFlags.NoFocusOnAppearing |
					ImGuiWindowFlags.NoNav
	
	if ImGui.Begin("Object Picker", true, window_flags)
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
					if ImGui.BeginListBox(concat("##", cat.name, " list"), 238, 256)
					{
						for (var j = 0, m = array_length(cat.objects); j < m; j++)
						{
							var obj = cat.objects[j]
							var spr = config_get_object_sprite(obj)
							
							ImGui.Image(spr, 0, c_white, 1, 32, 32)
							ImGui.SameLine()
							if ImGui.Selectable(obj.name, false, ImGuiSelectableFlags.None, 0, 32)
							{
								deselectObject()
								lastObject = obj
								with (instance_create_depth(mouse_x, mouse_y, -10, obj_objectPlacer))
								{
									objectData = obj
									layerName = other.currentLayer
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

function ui_layerlist()
{
	if !windows.layerlist
		exit;
	
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
				if layer_exists(arr[i].name)
				{
					var layVisible = layer_get_visible(arr[i].name)
					var newVisible = ImGui.Checkbox("##visible" + arr[i].displayName, layVisible)
					if (newVisible != layVisible)
						layer_set_visible(arr[i].name, newVisible)
						
					ImGui.SameLine()
				}
				
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

#macro VARTYPE_DEFAULT "default"
#macro VARTYPE_BOOL "bool"
#macro VARTYPE_NUMBER "number"
#macro VARTYPE_STRING "string"

global.varTypes = [VARTYPE_DEFAULT, VARTYPE_BOOL, VARTYPE_NUMBER, VARTYPE_STRING]

function ui_inspector()
{
	if !windows.inspector
		exit;
	
	if !config_loaded()
		exit;
	if instance_exists(obj_objectPlacer)
		exit;
		
	ImGui.SetNextWindowPos(room_width - 10, 32, ImGuiCond.Always, 1, 0)
	var window_flags = ImGuiWindowFlags.NoDecoration |
					ImGuiWindowFlags.AlwaysAutoResize |
					ImGuiWindowFlags.NoSavedSettings |
					ImGuiWindowFlags.NoFocusOnAppearing |
					ImGuiWindowFlags.NoNav
	
	if ImGui.Begin("Inspector", true, window_flags)
	{
		ImGui.Text("Inspector")
		ImGui.Separator()
		
		if (selectedObject != undefined)
		{
			ImGui.Text(selectedObject.objectID)
			ImGui.NewLine()
			
			ImGui.Text("Position")
			
			var ox = ImGui.InputInt("X", selectedObject.x, 1, 5)
			selectedObject.x = ox
			
			var oy = ImGui.InputInt("Y", selectedObject.y, 1, 5)
			selectedObject.y = oy
			
			ImGui.NewLine()
			
			if selectedObject.canResize
			{
				ImGui.Text("Scale")
				
				var oxscale = ImGui.InputFloat("X##Scale", selectedObject.image_xscale, 0.25, 1)
				selectedObject.image_xscale = oxscale
				
				var oyscale = ImGui.InputFloat("Y##Scale", selectedObject.image_yscale, 0.25, 1)
				selectedObject.image_yscale = oyscale
			}
			
			ImGui.Separator()
			
			ImGui.Text("Variables")
			
			if ImGui.BeginListBox("##Variable Listbox")
			{
				for (var i = 0, n = array_length(selectedObject.variables); i < n; i++)
				{
					var variable = selectedObject.variables[i]
					var name = variable[0]
					var value = variable[1]
					var type = variable[2]
					
					var listval = value
					switch type
					{
						case VARTYPE_DEFAULT:
							listval = ""
							break
						case VARTYPE_BOOL:
							listval = value ? "true" : "false"
							break
						case VARTYPE_NUMBER:
							if (frac(abs(value)) <= 0)
								listval = floor(value)
							break
						case VARTYPE_STRING:
							listval = concat("\"", value, "\"")
							break
					}
					var liststr = concat(name, " = ", listval, " ( ", type, " )")
					
					if ImGui.Selectable(liststr)
						ImGui.OpenPopup("varMenuPopup##" + string(i))
					
					// object variable popup menu
					var openEditPopup = false
					if ImGui.BeginPopupContextItem("varMenuPopup##" + string(i))
					{
						if ImGui.Selectable("Edit##" + string(i))
						{
							selectedVariableIndex = i
							openEditPopup = true
						}
						if ImGui.Selectable("Delete##" + string(i))
						{
							array_delete(selectedObject.variables, i, 1)
							i--
							n--
						}
						ImGui.EndPopup()
					}
					
					if openEditPopup
						ImGui.OpenPopup("varPopup##" + string(i))
					
					// object variable edit popup
					ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Always, 0.5, 0.5)
					if ImGui.BeginPopup("varPopup##" + string(i))
					{
						if (selectedObject != undefined)
						{
							var ovar = selectedObject.variables[selectedVariableIndex]
							var vname = ovar[0]
							var vval = ovar[1]
							var vtype = ovar[2]
							
							var nname = ImGui.InputText("Name", vname)
							ovar[0] = nname
							
							switch vtype
							{
								case VARTYPE_BOOL:
									var nval = ImGui.Checkbox("Enabled", vval)
									ovar[1] = nval
									break
									
								case VARTYPE_NUMBER:
									var nval = ImGui.InputFloat("Value", vval, 1, 2)
									ovar[1] = nval
									break
									
								case VARTYPE_STRING:
									var nval = ImGui.InputText("Value", vval)
									ovar[1] = nval
									break
							}
							
							ImGui.Separator()
							if ImGui.BeginCombo("Type", vtype, 0)
							{
								for (var j = 0, m = array_length(global.varTypes); j < m; j++)
								{
									var arrtype = global.varTypes[j]
									var arrselected = (vtype == arrtype)
									
									if ImGui.Selectable(arrtype, arrselected)
									{
										// try to convert the current value to the new type
										switch arrtype
										{
											case VARTYPE_BOOL:
												if is_string(vval)
												{
													vval = string_digits(vval)
													if (vval == "")
														vval = 0
													else
														vval = real(vval)
												}
												vval = bool(vval)
												break
											case VARTYPE_NUMBER:
												if is_string(vval)
												{
													vval = string_digits(vval)
													if (vval == "")
														vval = 0
												}
												vval = real(vval)
												break
											case VARTYPE_STRING:
												vval = string(vval)
												break
										}
										
										ovar[1] = vval
										ovar[2] = arrtype
									}
									
									if arrselected
										ImGui.SetItemDefaultFocus()
								}
								ImGui.EndCombo()
							}
							ImGui.NewLine()
							
							if ImGui.Button("OK", BUTTON_WIDTH, BUTTON_HEIGHT)
								ImGui.CloseCurrentPopup()
						}
						ImGui.EndPopup()
					}
				}
				
				if ImGui.Button("+", 20, 20)
				{
					var len = array_length(selectedObject.variables)
					array_push(selectedObject.variables, ["varname" + string(len + 1), false, VARTYPE_BOOL])
					
					selectedVariableIndex = len
					ImGui.OpenPopup("varPopup##" + string(selectedVariableIndex))
				}
				ImGui.EndListBox()
			}
			
			ImGui.NewLine()
			
			if ImGui.Button("Delete", BUTTON_WIDTH, BUTTON_HEIGHT)
			{
				instance_destroy(selectedObject)
				deselectObject()
			}
			
			ImGui.SameLine()
			if ImGui.Button("Unselect", BUTTON_WIDTH, BUTTON_HEIGHT)
				deselectObject()
		}
		else
		{
			// room settings
			var rmstr = "Untitled"
			if (!is_undefined(global.roomPath) && global.roomPath != "")
				rmstr = filename_change_ext(filename_name(global.roomPath), "")
			
			ImGui.Text(rmstr)
			ImGui.NewLine()
			
			if (obj_roomManager.roomFormat == ROOMFORMAT_CYOP)
			{
				ImGui.SetNextItemWidth(224)
				var offx = ImGui.DragInt("X", obj_roomManager.cyopRoomInfo.offsetX)
				obj_roomManager.cyopRoomInfo.offsetX = offx
			
				ImGui.SetNextItemWidth(224)
				var offy = ImGui.DragInt("Y", obj_roomManager.cyopRoomInfo.offsetY)
				obj_roomManager.cyopRoomInfo.offsetY = offy
			}
			else
			{
				ImGui.SetNextItemWidth(224)
				var title = ImGui.InputText("Title", obj_roomManager.roomInfo.title)
				obj_roomManager.roomInfo.title = title
			}
			
			ImGui.Separator()
			
			ImGui.SetNextItemWidth(224)
			var width = ImGui.DragInt("Width", obj_roomManager.roomInfo.width)
			obj_roomManager.roomInfo.width = max(width, global.config.roomDefaults.width)
			
			ImGui.SetNextItemWidth(224)
			var height = ImGui.DragInt("Height", obj_roomManager.roomInfo.height)
			obj_roomManager.roomInfo.height = max(height, global.config.roomDefaults.height)
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
		ImGui.Text("Welcome to Room Factory version " + GM_version)
		ImGui.Separator()
		
		ImGui.Text("Select a game configuration:")
		
		static searched = false
		static searcharr = []
		static selection = 0
		
		if !searched
		{
			var file = file_find_first(concat(CONFIG_PATH, "*.rfcfg"), fa_none)
			while (file != "")
			{
				var jfile = file_text_read_all(concat(CONFIG_PATH, file))
				var json = json_parse(jfile)
				
				array_push(searcharr, [file, json.name])
				file = file_find_next()
			}
			
			searched = true
		}
		
		if ImGui.BeginListBox("##Config Listbox", 300, 260)
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

function ui_errormessage()
{
	ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Always, 0.5, 0.5)
	
	if ImGui.BeginPopup("Error", ImGuiWindowFlags.NoDecoration | ImGuiWindowFlags.NoResize)
	{
		ImGui.Text("Error")
		ImGui.Separator()
	
		ImGui.Text(errorText)
		if (errorText2 != "")
			ImGui.Text(errorText2)
	
		ImGui.NewLine()
		if ImGui.Button("OK", BUTTON_WIDTH, BUTTON_HEIGHT)
			ImGui.CloseCurrentPopup()
		ImGui.EndPopup()
	}
	
	if showError
	{
		ImGui.OpenPopup("Error")
		showError = false
	}
}

function error_message(str, str2 = "")
{
	with (obj_mainUI)
	{
		errorText = str
		errorText2 = str2
		showError = true
	}
}

function update_titlebar()
{
	var rftitle = "Room Factory"
	var str = rftitle
	if (is_undefined(global.roomPath) || global.roomPath == "")
		str = concat("[Untitled] - ", rftitle)
	else
		str = concat("[", filename_change_ext(filename_name(global.roomPath), ""), "] - ", rftitle)
		
	window_set_caption(str)
}

function draw_mouse_tooltip(offx, offy, str)
{
	draw_set_font(mainFont)
	draw_text(realmouse_x + offx, realmouse_y + offy, str)
}