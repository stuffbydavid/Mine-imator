/// block_tile_entity_bed(map)
/// @arg map

function block_tile_entity_bed(map)
{
	var colorid = map[?"color"];
	
	if (!is_real(colorid))
		return 0
	
	if (colorid >= ds_list_size(minecraft_color_list))
		return 0
	
	builder_set(block_state_id, build_pos_x, build_pos_y, build_pos_z, block_set_state_id_value(block_current, block_state_id_current, "color", minecraft_color_name_list[|colorid]))
}
