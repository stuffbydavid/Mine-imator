/// tab_control(height)
/// @arg height

tab_control_h = argument0

if (tab_collumns)
{
	dw = tab_collumns_width/tab_collumns_count
	dx = dx_start + floor(dw * (tab_collumns_index))
}
