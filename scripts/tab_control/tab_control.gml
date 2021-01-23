/// tab_control(height)
/// @arg height

tab_control_h = argument0

if (tab_collumns)
{
	dw = (tab_collumns_width - ((tab_collumns_count - 1) * 8)) / tab_collumns_count
	dx = dx_start + ceil(dw * (tab_collumns_index)) + (8 * tab_collumns_index)
}
