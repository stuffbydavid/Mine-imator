/// block_set_cave_vines()

function block_set_cave_vines()
{
	var berries = block_get_state_id_value(block_current, block_state_id_current, "berries");
	block_set_tall_vine_down("type", "cave_vines_plant")
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "berries", berries)
	
	return 0
}