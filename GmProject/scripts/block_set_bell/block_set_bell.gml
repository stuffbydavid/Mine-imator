/// @desc Updates wall attachments to match the bell's remaining supports.

function block_set_bell()
{
	if (!build_edit || builder_mode != e_builder_mode.GENERATE)
		return 0

	var attachment = block_get_state_id_value(block_current, block_state_id_current, "attachment");
	if (attachment != "single_wall" && attachment != "double_wall")
		return 0

	// Find the two wall directions along the attachment axis
	var facing, facingdir, supports;
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	facingdir = XP
	supports = 0
	for (var d = XP; d <= YN; d++)
		if (dir_names[d] = facing)
			facingdir = d

	// A single remaining wall determines the attachment direction
	var axis = (facingdir div 2) * 2;
	for (var d = axis; d < axis + 2; d++)
	{
		if (!build_edge[d] && block_face_full[d])
		{
			supports++
			facingdir = d
		}
	}

	if (supports = 2)
		attachment = "double_wall"
	else if (supports = 1)
	{
		attachment = "single_wall"
		block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "facing", dir_names[facingdir])
	}
	else
	{
		// With no walls, prefer a floor support over a ceiling support
		if (!build_edge[ZN] && block_face_full[ZN])
			attachment = "floor"
		else if (!build_edge[ZP] && block_face_full[ZP])
			attachment = "ceiling"
	}

	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "attachment", attachment)

	return 0
}
