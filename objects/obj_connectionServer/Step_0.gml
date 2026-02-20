if testMode
{
	ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Always, 0.5, 0.5)
	ImGui.SetNextWindowFocus()
	
	if ImGui.Begin("Waiting For Connection", undefined, ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.Modal | ImGuiWindowFlags.NoSavedSettings | ImGuiWindowFlags.NoCollapse)
	{
		ImGui.Text("Waiting for a game to connect...")
		
		ImGui.SameLine()
		if ImGui.Button("Cancel", BUTTON_WIDTH, BUTTON_HEIGHT)
			instance_destroy()
		
		ImGui.Separator()
		ImGui.Text($"Timeout in: {floor(testModeTimeout / 60)}")
		
		ImGui.End()
	}
	
	if (testModeTimeout > 0)
		testModeTimeout--
	else
	{
		print("Connection test timeout")
		error_message("Connection test timed out")
		instance_destroy()
	}
}