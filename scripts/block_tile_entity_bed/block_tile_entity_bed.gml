/// block_tile_entity_bed(map)
/// @arg map

var map, colorid;
map = argument0
colorid = map[?"color"]

if (!is_real(colorid))
	return 0

var colorarr = block_current.states_map[?"color"].value_name;

if (colorid >= array_length_1d(colorarr))
	return 0

array3D_set(block_state_id, build_size_z, build_pos_x, build_pos_y, build_pos_z, block_set_state_id_value(block_current, block_state_id_current, "color", colorarr[colorid]))