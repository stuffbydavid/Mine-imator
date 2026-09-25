/// tl_find_save_ids()

function tl_find_save_ids()
{
	temp = save_id_find(temp)
	parent = save_id_find(parent)
	part_of = save_id_find(part_of)
	glint_tex = save_id_find(glint_tex)

	if (type = e_tl_type.BLOCK && part_of = null && !has_temp)
	{
		block_tex = save_id_find(block_tex)
		block_tex_material = save_id_find(block_tex_material)
		block_tex_normal = save_id_find(block_tex_normal)
	}
	else if (type = e_tl_type.SPECIAL_BLOCK && part_of = null && !has_temp)
	{
		model_tex = save_id_find(model_tex)
		model_tex_material = save_id_find(model_tex_material)
		model_tex_normal = save_id_find(model_tex_normal)
	}
	else if (type = e_tl_type.TEXT && part_of = null && !has_temp)
		text_font = save_id_find(text_font)
}
