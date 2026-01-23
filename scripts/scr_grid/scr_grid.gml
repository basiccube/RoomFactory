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