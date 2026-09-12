/// res_load_pack_block_textures()
/// @desc Creates a static and animated block sheet out of the list of block textures.

function res_load_pack_block_textures()
{
	// Free old
	for (var size = 0; size < e_block_sheet.static_amount; size++)
	{
		if (block_sheet_texture[size] != null)
			texture_free(block_sheet_texture[size])
		if (block_sheet_texture_material[size] != null)
			texture_free(block_sheet_texture_material[size])
		if (block_sheet_texture_normal[size] != null)
			texture_free(block_sheet_texture_normal[size])
	
		block_sheet_texture[size] = null
		block_sheet_texture_material[size] = null
		block_sheet_texture_normal[size] = null
	}
	
	if (block_sheet_texture[e_block_sheet.ANIMATED] != null)
		for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
			texture_free(block_sheet_texture[e_block_sheet.ANIMATED][f])
	
	if (block_sheet_texture_material[e_block_sheet.ANIMATED] != null)
		for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
			texture_free(block_sheet_texture_material[e_block_sheet.ANIMATED][f])
	
	if (block_sheet_texture_normal[e_block_sheet.ANIMATED] != null)
		for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
			texture_free(block_sheet_texture_normal[e_block_sheet.ANIMATED][f])

	block_sheet_texture[e_block_sheet.ANIMATED] = null
	block_sheet_texture_material[e_block_sheet.ANIMATED] = null
	block_sheet_texture_normal[e_block_sheet.ANIMATED] = null
	
	if (block_sheet_depth_list != null)
		ds_list_destroy(block_sheet_depth_list)
	
	if (block_sheet_ani_depth_list != null)
		ds_list_destroy(block_sheet_ani_depth_list)
	
	// Create new
	res_load_pack_block_sheet("diffuse", "") // Diffuse
	
	if (id != mc_res)
	{
		res_load_pack_block_sheet("material", "_s") // Material
		res_load_pack_block_sheet("normal", "_n") // Normal map
	}
	else
	{
		for (var size = 0; size < e_block_sheet.static_amount; size++)
			if (block_sheet_texture[size] != null)
				block_sheet_texture_material[size] = texture_duplicate(spr_default_material)
		
		block_sheet_texture_material[e_block_sheet.ANIMATED] = array_create(minecraft_block_animated_sheet_frame_count)
		for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
			block_sheet_texture_material[e_block_sheet.ANIMATED][f] = texture_duplicate(spr_default_material)
		
		for (var size = 0; size < e_block_sheet.static_amount; size++)
			if (block_sheet_texture[size] != null)
				block_sheet_texture_normal[size] = texture_duplicate(spr_default_normal)
		
		block_sheet_texture_normal[e_block_sheet.ANIMATED] = array_create(minecraft_block_animated_sheet_frame_count)
		for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
			block_sheet_texture_normal[e_block_sheet.ANIMATED][f] = texture_duplicate(spr_default_normal)
	}
	
	log("Block textures all", "done")
}
