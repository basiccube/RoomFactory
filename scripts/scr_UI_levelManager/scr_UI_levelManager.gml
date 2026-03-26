function levelManager_window()
{
	if !showManagerWindow
		exit;
	if !isOpen()
		exit;
	
	var roomOpen = ROOM_IS_OPEN
	var flags = ImGuiWindowFlags.AlwaysAutoResize
	if !roomOpen
	{
		ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Always, 0.5, 0.5)
		flags |= ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.NoSavedSettings
	}
	else
		ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.FirstUseEver, 0.5, 0.5)

	var show = ImGui.Begin("Level Manager", showManagerWindow, flags, ImGuiReturnMask.Both)
	showManagerWindow = show & ImGuiReturnMask.Pointer
	
	if (show & ImGuiReturnMask.Return)
	{
		if !roomOpen
		{
			ImGui.Text("Level Manager")
			ImGui.Separator()
		}
	
		levelManager_tabs()
		ImGui.Separator()
	
		levelManager_info()
	
		ImGui.Separator()
		levelManager_buttons()
	}

	ImGui.End()
}

function levelManager_info()
{
	info.name = ImGui.InputText("Name", info.name)
	if ImGui.BeginCombo("First Room", info.firstRoom, ImGuiComboFlags.None)
	{
		for (var i = 0, n = array_length(roomList); i < n; i++)
		{
			var p = filename_change_ext(roomList[i], "")
			var selected = (info.firstRoom == p)
			
			if ImGui.Selectable(p, selected)
				info.firstRoom = p
			
			if selected
				ImGui.SetItemDefaultFocus()
		}
		ImGui.EndCombo()
	}
}

function levelManager_buttons()
{
	if ImGui.Button("Save Level", BUTTON_WIDTH, BUTTON_HEIGHT)
	{
		saveLevel()
		if ROOM_IS_OPEN
			save_room(global.roomPath)
	}
	
	ImGui.SameLine()
	if ImGui.Button("Close Level", BUTTON_WIDTH, BUTTON_HEIGHT)
	{
		closeLevel()
		if ROOM_IS_OPEN
			clear_room()
	}
}

function levelManager_tabs()
{
	var musicPath = levelPath + "music/"
	var roomPath = levelPath + "rooms/"
	
	if ImGui.BeginTabBar("Level Manager Tabs")
	{
		if ImGui.BeginTabItem("Rooms")
		{
			static roomRenameFilename = ""
			if ImGui.BeginListBox("##Rooms Listbox", 350, 250)
			{
				var stop = false
				for (var i = 0, n = array_length(roomList); i < n; i++)
				{
					var p = filename_change_ext(roomList[i], "")
					
					var popupStr = "roomPopup##" + string(i)
					var renameStr = "roomRenamePopup##" + string(i)
					var deleteStr = "roomDeletePopup##" + string(i)
					
					if ImGui.Selectable(p)
						ImGui.OpenPopup(popupStr)
						
					var openRenamePopup = false
					var openDeletePopup = false
					if ImGui.BeginPopupContextItem(popupStr)
					{
						if ImGui.Selectable("Edit##" + string(i))
						{
							if load_room(roomPath + roomList[i])
								showManagerWindow = false
						}
						if ImGui.Selectable("Rename##" + string(i))
						{
							roomRenameFilename = p
							openRenamePopup = true
						}
						if ImGui.Selectable("Delete##" + string(i))
							openDeletePopup = true
						ImGui.EndPopup()
					}
					
					if openRenamePopup
						ImGui.OpenPopup(renameStr)
					if openDeletePopup
						ImGui.OpenPopup(deleteStr)
					
					// rename popup
					ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Always, 0.5, 0.5)
					if ImGui.BeginPopup(renameStr)
					{
						ImGui.Text("Rename room to:")
						roomRenameFilename = ImGui.InputText("##Name", roomRenameFilename)
						
						ImGui.SameLine()
						if ImGui.Button("OK", BUTTON_WIDTH, BUTTON_HEIGHT)
						{
							file_rename(roomPath + roomList[i], roomPath + roomRenameFilename + config_get_file_filter().room_ext)
							getRooms()
							
							stop = true
							ImGui.CloseCurrentPopup()
						}
						
						ImGui.EndPopup()
					}
					
					// delete popup
					ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Always, 0.5, 0.5)
					if ImGui.BeginPopup(deleteStr)
					{
						ImGui.Text("Delete room " + roomList[i] + "?")
						
						if ImGui.Button("Yes", BUTTON_WIDTH, BUTTON_HEIGHT)
						{
							if (ROOM_IS_OPEN && filename_name(global.roomPath) == roomList[i])
								clear_room()
							
							file_delete(roomPath + roomList[i])
							getRooms()
							
							stop = true
							ImGui.CloseCurrentPopup()
						}
						
						ImGui.SameLine()
						if ImGui.Button("No", BUTTON_WIDTH, BUTTON_HEIGHT)
							ImGui.CloseCurrentPopup()
						
						ImGui.EndPopup()
					}
					
					if stop
						break;
				}
				
				if ImGui.Button("+", 20, 20)
				{
					var len = array_length(roomList)
					var prevRoom = global.roomPath
					
					if (!is_undefined(prevRoom) && prevRoom != "")
						save_room(global.roomPath)
					
					// stinky
					clear_room()
					save_room(roomPath + "NewRoom" + string(len + 1) + config_get_file_filter().room_ext)
					clear_room()
					
					if (!is_undefined(prevRoom) && prevRoom != "")
						load_room(prevRoom)
					
					getRooms()
				}
				
				ImGui.EndListBox()
			}
			ImGui.EndTabItem()
		}
		
		if ImGui.BeginTabItem("Music")
		{
			static musicRenameFilename = ""
			if ImGui.BeginListBox("##Music Listbox", 350, 250)
			{
				var stop = false
				for (var i = 0, n = array_length(musicList); i < n; i++)
				{
					var p = musicList[i]
					
					var popupStr = "musicPopup##" + string(i)
					var renameStr = "musicRenamePopup##" + string(i)
					var deleteStr = "musicDeletePopup##" + string(i)
					
					if ImGui.Selectable(p)
						ImGui.OpenPopup(popupStr)
					
					var openRenamePopup = false
					var openDeletePopup = false
					if ImGui.BeginPopupContextItem(popupStr)
					{
						if ImGui.Selectable("Rename##" + string(i))
						{
							musicRenameFilename = p
							openRenamePopup = true
						}
						if ImGui.Selectable("Delete##" + string(i))
							openDeletePopup = true
						ImGui.EndPopup()
					}
					
					if openRenamePopup
						ImGui.OpenPopup(renameStr)
					if openDeletePopup
						ImGui.OpenPopup(deleteStr)
					
					// rename popup
					ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Always, 0.5, 0.5)
					if ImGui.BeginPopup(renameStr)
					{
						ImGui.Text("Rename file to:")
						musicRenameFilename = ImGui.InputText("##Filename", musicRenameFilename)
						
						ImGui.SameLine()
						if ImGui.Button("OK", BUTTON_WIDTH, BUTTON_HEIGHT)
						{
							file_rename(musicPath + musicList[i], musicPath + musicRenameFilename)
							getMusic()
							
							stop = true
							ImGui.CloseCurrentPopup()
						}
						
						ImGui.EndPopup()
					}
					
					// delete popup
					ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Always, 0.5, 0.5)
					if ImGui.BeginPopup(deleteStr)
					{
						ImGui.Text("Delete music file " + musicList[i] + "?")
						
						if ImGui.Button("Yes", BUTTON_WIDTH, BUTTON_HEIGHT)
						{
							file_delete(musicPath + musicList[i])
							getMusic()
							
							stop = true
							ImGui.CloseCurrentPopup()
						}
						
						ImGui.SameLine()
						if ImGui.Button("No", BUTTON_WIDTH, BUTTON_HEIGHT)
							ImGui.CloseCurrentPopup()
						
						ImGui.EndPopup()
					}
					
					if stop
						break;
				}
				
				if ImGui.Button("+", 20, 20)
				{
					var musicfile = get_open_filename_ext("Ogg Vorbis files (*.ogg)|*.ogg", "", "", "Add music file to level...")
					if (musicfile != "")
					{
						print("Adding ", musicfile, " to level")
						file_copy(musicfile, musicPath + filename_name(musicfile))
						getMusic()
					}
				}
				
				ImGui.EndListBox()
			}
			ImGui.EndTabItem()
		}
		
		ImGui.EndTabBar()
	}
}