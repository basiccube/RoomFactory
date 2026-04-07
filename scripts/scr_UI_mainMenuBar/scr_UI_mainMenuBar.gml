#macro RESET_ALL	obj_levelManager.closeLevel()	\
					clear_room()

function is_level_file(str)
{ return filename_ext(str) == config_get_file_filter().level_ext; }

function menu_new()
{ clear_room(); }

function menu_open()
{
	var filter = config_get_file_filter()
	var p = get_open_filename(filter.combined, "")
	if (p != "")
	{
		RESET_ALL
		
		if is_level_file(p)
		{
			obj_levelManager.openLevel(p)
			obj_levelManager.showManagerWindow = true
		}
		else
			load_room(p)
		
		recents_push(p)
	}
}

function menu_save()
{
	save_room(global.roomPath)
	if !obj_levelManager.isOpen()
		recents_push(global.roomPath)
}

function menu_save_as()
{
	save_room()
	if !obj_levelManager.isOpen()
		recents_push(global.roomPath)
}

function menu_level_save_close()
{
	save_room(global.roomPath)
	menu_level_close()
}

function menu_level_close()
{
	clear_room()
	obj_levelManager.showManagerWindow = true
}

function menu_handle_shortcuts()
{
	if !keyboard_check(vk_control)
		exit;
		
	// file menu
	if (keyboard_check_pressed(ord("N")) && !obj_levelManager.isOpen())
		menu_new()
	if (keyboard_check_pressed(ord("O")) && !obj_levelManager.isOpen())
		menu_open()
	if keyboard_check_pressed(ord("S"))
	{
		if keyboard_check(vk_shift)
			menu_save_as()
		else
			menu_save()
	}
	
	if (keyboard_check_pressed(ord("W")) && obj_levelManager.isOpen())
	{
		if keyboard_check(vk_shift)
			menu_level_save_close()
		else
			menu_level_close()
	}
}

function ui_mainmenubar()
{
	ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, 12, 6)
	ImGui.BeginMainMenuBar()
	
	if ImGui.BeginMenu("File")
	{
		// Cant create a new room or open an existing one
		// while a level is open
		if !obj_levelManager.isOpen()
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
					var recent = settings.recents[i]
					if is_undefined(recent)
						continue;
				
					if ImGui.MenuItem(recent)
					{
						RESET_ALL
					
						if is_level_file(recent)
						{
							obj_levelManager.openLevel(recent)
							obj_levelManager.showManagerWindow = true
						}
						else
							load_room(recent)
					
						recents_push(recent)
					}
				}
				
				ImGui.Separator()
				if ImGui.MenuItem("Clear Recents")
					recents_clear()
				
				ImGui.EndMenu()
			}
		
			ImGui.Separator()
		}
		
		if ImGui.MenuItem("Save", "Ctrl+S")
			menu_save()
		if ImGui.MenuItem("Save As...", "Ctrl+Shift+S")
			menu_save_as()
		
		// These menu options close the currently loaded room
		// and return you back to the level manager window
		if obj_levelManager.isOpen()
		{
			ImGui.Separator()
			if ImGui.MenuItem("Save and Close", "Ctrl+Shift+W")
				menu_level_save_close()
			if ImGui.MenuItem("Close Room", "Ctrl+W")
				menu_level_close()
		}
		
		ImGui.Separator()
		if ImGui.MenuItem("Quit")
			game_end()
			
		ImGui.EndMenu()
	}
	
	if ImGui.BeginMenu("Edit")
	{
		if ImGui.MenuItem("Preferences")
			showSettings = true
		ImGui.EndMenu()
	}
	
	if ImGui.BeginMenu("View")
	{
		if ImGui.MenuItem("Show Grid", undefined, viewOptions.drawGrid)
			viewOptions.drawGrid = !viewOptions.drawGrid
		if ImGui.MenuItem("Show Layer Names", undefined, viewOptions.showLayerNames)
			viewOptions.showLayerNames = !viewOptions.showLayerNames
		if ImGui.MenuItem("Darken Unselected Layers", undefined, viewOptions.darkenLayers)
			viewOptions.darkenLayers = !viewOptions.darkenLayers
			
		ImGui.Separator()
		if ImGui.BeginMenu("Windows")
		{
			if ImGui.MenuItem("Layer-specific Window", undefined, windows.layertypes)
				windows.layertypes = !windows.layertypes
			if ImGui.MenuItem("Layer List", undefined, windows.layerlist)
				windows.layerlist = !windows.layerlist
			if ImGui.MenuItem("Inspector", undefined, windows.inspector)
				windows.inspector = !windows.inspector
			if ImGui.MenuItem("Grid Size", undefined, windows.gridsize)
				windows.gridsize = !windows.gridsize
			ImGui.EndMenu()
		}
		
		ImGui.EndMenu()
	}
	
	if ImGui.BeginMenu("Connect")
	{
		ImGui.TextDisabled($"Server {GameConnection.server >= 0 ? "running" : "stopped"}")
		
		if ImGui.MenuItem("Start Server")
			GameConnection.StartServer()
		if ImGui.MenuItem("Stop Server")
			GameConnection.StopServer()
			
		ImGui.Separator()
		if ImGui.MenuItem("Test Room")
			GameConnection.TestRoomInGame()
		
		ImGui.Separator()
		if ImGui.MenuItem("Test Connection")
			GameConnection.TestConnection()
		
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
	
	// Menu button that opens up the level manager
	if obj_levelManager.isOpen()
	{
		ImGui.Separator()
		if ImGui.MenuItem("Level Manager")
			obj_levelManager.showManagerWindow = !obj_levelManager.showManagerWindow
	}
	
	ImGui.EndMainMenuBar()
	ImGui.PopStyleVar()
}