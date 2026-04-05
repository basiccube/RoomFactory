#macro INSPECTOR_CONTROL_WIDTH (224 * settings.scale)

function ui_inspector_room()
{
	var rmstr = "Untitled"
	if ROOM_IS_OPEN
		rmstr = filename_change_ext(filename_name(global.roomPath), "")
			
	ImGui.Text(rmstr)
	ImGui.Separator()
			
	if (obj_roomManager.roomFormat == ROOMFORMAT_CYOP)
	{
		ImGui.SetNextItemWidth(INSPECTOR_CONTROL_WIDTH)
		var offx = ImGui.DragInt("X", obj_roomManager.cyopRoomInfo.offsetX)
		obj_roomManager.cyopRoomInfo.offsetX = offx
			
		ImGui.SetNextItemWidth(INSPECTOR_CONTROL_WIDTH)
		var offy = ImGui.DragInt("Y", obj_roomManager.cyopRoomInfo.offsetY)
		obj_roomManager.cyopRoomInfo.offsetY = offy
	}
	else
	{
		ImGui.SetNextItemWidth(INSPECTOR_CONTROL_WIDTH)
		var title = ImGui.InputText("Title", obj_roomManager.roomInfo.title)
		obj_roomManager.roomInfo.title = title
	}
			
	ImGui.Separator()
			
	ImGui.SetNextItemWidth(INSPECTOR_CONTROL_WIDTH)
	var width = ImGui.DragInt("Width", obj_roomManager.roomInfo.width)
	obj_roomManager.roomInfo.width = max(width, global.config.roomDefaults.width)
			
	ImGui.SetNextItemWidth(INSPECTOR_CONTROL_WIDTH)
	var height = ImGui.DragInt("Height", obj_roomManager.roomInfo.height)
	obj_roomManager.roomInfo.height = max(height, global.config.roomDefaults.height)
			
	ImGui.Separator()
			
	var useCustomAnyway = !variable_struct_exists(global.config, "music")
	var comboTitle = obj_roomManager.musicTitle
			
	ImGui.SetNextItemWidth(INSPECTOR_CONTROL_WIDTH)
	if (!useCustomAnyway && ImGui.BeginCombo("Music", comboTitle, ImGuiComboFlags.HeightLarge))
	{
		if ImGui.Selectable("None", obj_roomManager.roomInfo.music == "" && !obj_roomManager.customMusic)
		{
			obj_roomManager.musicTitle = "None"
			obj_roomManager.roomInfo.music = ""
			obj_roomManager.customMusic = false
		}
		ImGui.Separator()
				
		for (var i = 0, n = array_length(global.config.music); i < n; i++)
		{
			var mus = global.config.music[i]
			if ImGui.CollapsingHeader(mus.header)
			{
				for (var j = 0, m = array_length(mus.list); j < m; j++)
				{
					var item = mus.list[j]
					var selected = (obj_roomManager.roomInfo.music == item.name)
							
					if ImGui.Selectable(item.displayName, selected)
					{
						obj_roomManager.musicTitle = item.displayName
						obj_roomManager.roomInfo.music = item.name
						obj_roomManager.customMusic = false
					}
							
					if selected
						ImGui.SetItemDefaultFocus()
				}
			}
		}
				
		ImGui.Separator()
		if ImGui.Selectable("Custom", obj_roomManager.customMusic)
		{
			if !obj_roomManager.customMusic
			{
				obj_roomManager.roomInfo.music = ""
				obj_roomManager.customMusic = true
			}
			obj_roomManager.musicTitle = "Custom"
		}
				
		if obj_roomManager.customMusic
			ImGui.SetItemDefaultFocus()
				
		ImGui.EndCombo()
	}
			
	if (obj_roomManager.customMusic || useCustomAnyway)
	{
		ImGui.SetNextItemWidth(INSPECTOR_CONTROL_WIDTH)
		if obj_levelManager.isOpen()
		{
			if ImGui.BeginCombo("##Custom Music", obj_roomManager.roomInfo.music, ImGuiComboFlags.None)
			{
				for (var i = 0, n = array_length(obj_levelManager.musicList); i < n; i++)
				{
					var mus = obj_levelManager.musicList[i]
					var selected = (obj_roomManager.roomInfo.music == mus)
							
					if ImGui.Selectable(mus, selected)
						obj_roomManager.roomInfo.music = mus
							
					if selected
						ImGui.SetItemDefaultFocus()
				}
						
				ImGui.EndCombo()
			}
		}
		else
			obj_roomManager.roomInfo.music = ImGui.InputText(useCustomAnyway ? "Music" : "##Music Path", obj_roomManager.roomInfo.music)
	}
}

#macro VARTYPE_DEFAULT "default"
#macro VARTYPE_BOOL "bool"
#macro VARTYPE_NUMBER "number"
#macro VARTYPE_STRING "string"

global.varTypes = [VARTYPE_DEFAULT, VARTYPE_BOOL, VARTYPE_NUMBER, VARTYPE_STRING]

function ui_inspector_selectable_object()
{
	var selectedObject = selectionArray[0]
	
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
					listval = $"\"{value}\""
					break
			}
			var liststr = $"{name} = {listval} ( {type} )"
					
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
		
		var addButtonSize = 20 * settings.scale
		if ImGui.Button("+", addButtonSize, addButtonSize)
		{
			var len = array_length(selectedObject.variables)
			array_push(selectedObject.variables, ["varname" + string(len + 1), false, VARTYPE_BOOL])
					
			selectedVariableIndex = len
			ImGui.OpenPopup("varPopup##" + string(selectedVariableIndex))
		}
		ImGui.EndListBox()
	}
			
	if ImGui.Button("Reset", BUTTON_WIDTH, BUTTON_HEIGHT)
	{
		var objdata = config_get_objectdata(selectedObject.objectID, config_get_current_layer().name)
		if !is_undefined(objdata)
			selectedObject.variables = config_get_object_variables(objdata)
	}
}

function ui_inspector_selectable()
{
	var selectedObject = selectionArray[0]
	
	var title = ""
	if (selectedObject.object_index == obj_layerObject)
		title = selectedObject.objectID
	else if (selectedObject.object_index == obj_layerSprite)
		title = selectedObject.spriteName
	
	if (title != "")
		ImGui.Text(title)
	ImGui.Separator()
			
	ImGui.Text("Position")
			
	var ox = ImGui.InputInt("X", selectedObject.x, 1, 5)
	selectedObject.x = ox
			
	var oy = ImGui.InputInt("Y", selectedObject.y, 1, 5)
	selectedObject.y = oy

	if selectedObject.canResize
	{
		ImGui.Text("Scale")
				
		var oxscale = ImGui.InputFloat("X##Scale", selectedObject.image_xscale, 0.25, 1)
		selectedObject.image_xscale = oxscale
				
		var oyscale = ImGui.InputFloat("Y##Scale", selectedObject.image_yscale, 0.25, 1)
		selectedObject.image_yscale = oyscale
	}
	
	if (selectedObject.object_index == obj_layerObject)
		ui_inspector_selectable_object()
	
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

function ui_inspector()
{
	if !windows.inspector
		exit;
	
	if !config_loaded()
		exit;
	if instance_exists(obj_placer)
		exit;
	
	var windowPosX = room_width - 10
	var windowPosY = 32
	if (settings.scale > 1)
		windowPosY *= settings.scale / 1.5
	
	ImGui.SetNextWindowPos(windowPosX, windowPosY, ImGuiCond.Always, 1, 0)
	var window_flags = ImGuiWindowFlags.NoDecoration |
					ImGuiWindowFlags.AlwaysAutoResize |
					ImGuiWindowFlags.NoSavedSettings |
					ImGuiWindowFlags.NoFocusOnAppearing |
					ImGuiWindowFlags.NoNav
	
	if ImGui.Begin("Inspector", true, window_flags)
	{
		ImGui.Text("Inspector")
		ImGui.Separator()
		
		if (array_length(selectionArray) > 0 && !isMultiSelection() && !is_undefined(selectionArray[0]))
			ui_inspector_selectable()
		else
			ui_inspector_room()
		
		ImGui.End()
	}
}