/// tl_new_block(tltype, source, [saved])
/// @arg tltype
/// @arg source
/// @arg [saved]

function tl_new_block(tltype, source, saved = false)
{
	with (new_obj(obj_timeline))
	{
		// Build and workbench placements share the same template-less timeline
		type = tltype
		temp = id
		has_temp = false
		animated = false
		inherit_rot_point = true
		inherit_alpha = true
		inherit_color = true
		inherit_texture = true

		if (type = e_tl_type.BLOCK)
		{
			block_name = source.block_name
			block_state = array_copy_1d(source.block_state)
			block_tex = source.block_tex
			block_tex_material = source.block_tex_material
			block_tex_normal = source.block_tex_normal
			block_repeat_enable = source.block_repeat_enable
			block_repeat = array_copy_1d(source.block_repeat)
			block_center_legacy = false
			block_center = source.block_center
			block_randomize = source.block_randomize
			block_vbuffer = null
			texture_filtering = true

			if (saved)
			{
				// History snapshots store resource save IDs
				block_tex = save_id_find(block_tex)
				block_tex_material = save_id_find(block_tex_material)
				block_tex_normal = save_id_find(block_tex_normal)
			}

			tl_update_scenery_part()
			temp_update_rot_point()
		}
		
		else if (type = e_tl_type.SPECIAL_BLOCK)
		{
			model_name = source.model_name
			model_state = array_copy_1d(source.model_state)
			model_tex = source.model_tex
			model_tex_material = source.model_tex_material
			model_tex_normal = source.model_tex_normal
			model_use_blend_color = source.model_use_blend_color
			model_blend_color = source.model_blend_color
			model_blend_color_default = source.model_blend_color_default
			pattern_base_color = source.pattern_base_color
			pattern_pattern_list = array_copy_1d(source.pattern_pattern_list)
			pattern_color_list = array_copy_1d(source.pattern_color_list)

			if (saved)
			{
				model_tex = save_id_find(model_tex)
				model_tex_material = save_id_find(model_tex_material)
				model_tex_normal = save_id_find(model_tex_normal)
			}

			tl_update_scenery_part()
			part_list = ds_list_create()
			if (model_file != null)
			{
				for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
				{
					var part = model_file.file_part_list[|p];
					if (model_hide_list = null || ds_list_find_index(model_hide_list, part.name) = -1)
						ds_list_add(part_list, tl_new_part(part))
				}
				tl_update_part_list(model_file, id)
			}
		}

		tl_update()
		tl_set_parent_root()
		tl_value_spawn()
		
		return id
	}
}
