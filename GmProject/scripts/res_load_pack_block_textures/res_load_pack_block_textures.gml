/// res_load_pack_block_textures()
/// @desc Creates a static and animated block sheet out of the list of block textures.

function res_load_pack_block_textures()
{
	// Free old
	if (block_sheet_texture != null)
		texture_free(block_sheet_texture)
	
	if (block_sheet_texture_material != null)
		texture_free(block_sheet_texture_material)
	
	if (block_sheet_tex_normal != null)
		texture_free(block_sheet_tex_normal)
	
	if (block_sheet_ani_texture != null)
		for (var f = 0; f < minecraft_block_animated_sheet_size[2]; f++)
			texture_free(block_sheet_ani_texture[f])
	
	if (block_sheet_ani_texture_material != null)
		for (var f = 0; f < minecraft_block_animated_sheet_size[2]; f++)
			texture_free(block_sheet_ani_texture_material[f])
	
	if (block_sheet_ani_tex_normal != null)
		for (var f = 0; f < minecraft_block_animated_sheet_size[2]; f++)
			texture_free(block_sheet_ani_tex_normal[f])
	
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
		block_sheet_texture_material = texture_duplicate(spr_default_material)
		
		for (var f = 0; f < minecraft_block_animated_sheet_size[2]; f++)
			block_sheet_ani_texture_material[f] = texture_duplicate(spr_default_material)
		
		block_sheet_tex_normal = texture_duplicate(spr_default_normal)
		
		for (var f = 0; f < minecraft_block_animated_sheet_size[2]; f++)
			block_sheet_ani_tex_normal[f] = texture_duplicate(spr_default_normal)
	}
	
	log("Block textures all", "done")
}
