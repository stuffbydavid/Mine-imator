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

state_vars_set_value(block_state_current, "color", colorarr[colorid])