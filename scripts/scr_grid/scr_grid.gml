function grid_increase()
{
	gridSize += gridIncrement
	gridSize = clamp(gridSize, gridMinSize, gridMaxSize)
}

function grid_decrease()
{
	gridSize -= gridIncrement
	gridSize = clamp(gridSize, gridMinSize, gridMaxSize)
}

function grid_snap(xsize, ysize)
{
	var px = x
	var py = y
	
	move_snap(xsize, ysize)
	
	if (x > px)
		x -= xsize
	if (y > py)
		y -= ysize
}

function ui_gridsize()
{
	ImGui.SetNextWindowPos(room_width - 10, 32, ImGuiCond.Always, 1)
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