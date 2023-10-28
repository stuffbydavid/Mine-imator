/// block_tile_entity_bed(map)
/// @arg map

function block_tile_entity_bed(map)
{
	var colorid = map[?"color"];
	
	if (!is_real(colorid))
		return 0
	
	if (is_undefined(colorid) || colorid >= minecraft_swatch_dyes.size)
		return 0
	
	var newstate = block_set_state_id_value(block_current, block_state_id_current, "color", minecraft_swatch_dyes.color_names[colorid]);
	builder_set_state_id(build_pos_x, build_pos_y, build_pos_z, newstate)
}
