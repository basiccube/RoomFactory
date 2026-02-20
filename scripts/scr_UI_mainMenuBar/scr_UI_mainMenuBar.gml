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
				var recent = global.settings.recents[i]
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
	
	ImGui.EndMainMenuBar()
	ImGui.PopStyleVar()
}