/// block_tile_entity_bed(map)
/// @arg map

var map, colorid;
map = argument0
colorid = map[?"color"]

if (!is_real(colorid))
	return 0

var colorarr = array("white", "orange", "magenta", "light_blue",
					 "yellow", "lime", "pink", "gray",
					 "silver", "cyan", "purple", "blue",
					 "brown", "green", "red", "black");

if (colorid >= array_length_1d(colorarr))
	return 0

builder_set(block_state_id, build_pos_x, build_pos_y, build_pos_z, block_set_state_id_value(block_current, block_state_id_current, "color", colorarr[colorid]))