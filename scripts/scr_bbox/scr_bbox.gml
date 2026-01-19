#macro BBOX_EDGE_THRESHOLD 3

///@param {Real} x
///@param {Real} y
///@param {Id.Instance} inst
function bbox_on_left_edge(px, py, inst)
{
	return (px <= inst.bbox_left + BBOX_EDGE_THRESHOLD - 1);
}

///@param {Real} x
///@param {Real} y
///@param {Id.Instance} inst
function bbox_on_right_edge(px, py, inst)
{
	return (px >= inst.bbox_right - BBOX_EDGE_THRESHOLD);
}

///@param {Real} x
///@param {Real} y
///@param {Id.Instance} inst
function bbox_on_top_edge(px, py, inst)
{
	return (py <= inst.bbox_top + BBOX_EDGE_THRESHOLD - 1);
}

///@param {Real} x
///@param {Real} y
///@param {Id.Instance} inst
function bbox_on_bottom_edge(px, py, inst)
{
	return (py >= inst.bbox_bottom - BBOX_EDGE_THRESHOLD);
}