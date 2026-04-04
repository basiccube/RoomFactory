function ui_settings()
{
	if !showSettings
		exit;
	
	ImGui.SetNextWindowPos(room_width / 2, room_height / 2, ImGuiCond.Appearing, 0.5, 0.5)
	
	var show = ImGui.Begin("Preferences", showSettings, ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.NoDocking, ImGuiReturnMask.Both)
	showSettings = show & ImGuiReturnMask.Pointer
	
	static unsavedSettings = new settingsData()
	if (show & ImGuiReturnMask.Return)
	{
		if ImGui.IsWindowAppearing()
			unsavedSettings = variable_clone(settings)
		
		ImGui.Text("Theme Mode")
		if ImGui.RadioButton("Light", unsavedSettings.theme == SettingsTheme.Light)
			unsavedSettings.theme = SettingsTheme.Light
		if ImGui.RadioButton("Dark", unsavedSettings.theme == SettingsTheme.Dark)
			unsavedSettings.theme = SettingsTheme.Dark
		
		ImGui.Text("UI Scale*")
		if ImGui.BeginCombo("##UIScale", $"{unsavedSettings.scale}X", ImGuiComboFlags.None)
		{
			for (var i = 1; i <= 3; i++)
			{
				if ImGui.Selectable($"{i}X", unsavedSettings.scale == i)
					unsavedSettings.scale = i
			}
			ImGui.EndCombo()
		}
		
		ImGui.NewLine()
		ImGui.Text("*Requires a restart")
		
		ImGui.Separator()
		if ImGui.Button("OK", BUTTON_WIDTH, BUTTON_HEIGHT)
		{
			settings = variable_clone(unsavedSettings)
			settings_apply()
			showSettings = false
		}
		
		ImGui.SameLine()
		if ImGui.Button("Cancel", BUTTON_WIDTH, BUTTON_HEIGHT)
			showSettings = false
		
		ImGui.SameLine()
		if ImGui.Button("Apply", BUTTON_WIDTH, BUTTON_HEIGHT)
		{
			settings = variable_clone(unsavedSettings)
			settings_apply()
		}
	}
	
	ImGui.End()
}