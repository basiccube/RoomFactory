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

function update_titlebar(edited = false)
{
	var rftitle = "Room Factory"
	var filestr = "Untitled"
	if ROOM_IS_OPEN
		filestr = filename_change_ext(filename_name(global.roomPath), "")
	
	var str = $"[{edited ? "*" : ""}{filestr}] - {rftitle}"
	window_set_caption(str)
}

function draw_mouse_tooltip(offx, offy, str, font = mainFont)
{
	draw_set_font(font)
	draw_text(realmouse_x + offx, realmouse_y + offy, str)
}

function draw_ui_text(x, y, str, font = mainFont)
{
	draw_set_font(font)
	draw_text(x, y, str)
}