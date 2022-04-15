/// tl_remove_clean([timeline])
/// @arg [timeline]
/// @desc Deletes timeline properties, used to help delete large hierarchies

function tl_remove_clean()
{
	var tl = (argument_count > 0 ? argument[0] : id);
	
	with (tl)
	{
		// Deselect
		tl_deselect()
		
		// Remove from render list
		ds_list_delete_value(render_list, id)
		
		// Remove from parent
		ds_list_delete_value(parent.tree_list, id)
		if (part_of != null)
			ds_list_delete_value(part_of.part_list, id)
		
		// Clear tree
		while (ds_list_size(tree_list) > 0)
			with (tree_list[|0])
				tl_remove_clean()
		
		ds_list_destroy(tree_list)
		
		if (part_list != null)
			ds_list_destroy(part_list)
		
		// Clear references
		if (part_of = null && temp != null)
			temp.count--
		
		if (type = e_tl_type.PATH_POINT)
			parent.path_update = true
		
		with (obj_template)
		{
			if (shape_tex = other.id)
				shape_tex = null
			
			if (shape_tex_material = other.id)
				shape_tex_material = null
			
			if (shape_tex_normal = other.id)
				shape_tex_normal = null
			
			if (type = e_temp_type.PARTICLE_SPAWNER && pc_spawn_region_path = other.id)
				pc_spawn_region_path = null
		}
		
		with (obj_bench_settings) 
		{
			if (shape_tex = other.id)
				shape_tex = null
			
			if (shape_tex_material = other.id)
				shape_tex_material = null
			
			if (shape_tex_normal = other.id)
				shape_tex_normal = null
		}
		
		with (obj_timeline)
		{
			if (value[e_value.TEXTURE_OBJ] = other.id)
				value[e_value.TEXTURE_OBJ] = null
			
			if (value[e_value.TEXTURE_MATERIAL_OBJ] = other.id)
				value[e_value.TEXTURE_MATERIAL_OBJ] = null
			
			if (value[e_value.TEXTURE_NORMAL_OBJ] = other.id)
				value[e_value.TEXTURE_NORMAL_OBJ] = null
			
			if (value[e_value.PATH_OBJ] = other.id)
				value[e_value.PATH_OBJ] = null
			
			if (value[e_value.IK_TARGET] = other.id)
				value[e_value.IK_TARGET] = null
			
			if (value[e_value.IK_TARGET_ANGLE] = other.id)
				value[e_value.IK_TARGET_ANGLE] = null
			
			if (value[e_value.ATTRACTOR] = other.id)
				value[e_value.ATTRACTOR] = null
			
			if (value_inherit[e_value.PATH_OBJ] = other.id)
				update_matrix = true
			
			if (value[e_value.IK_TARGET] = other.id)
				update_matrix = true
			
			if (value[e_value.IK_TARGET_ANGLE] = other.id)
				update_matrix = true
			
			if (value_inherit[e_value.ATTRACTOR] = other.id)
				update_matrix = true
			
			if (value_inherit[e_value.TEXTURE_OBJ] = other.id) 
				update_matrix = true
			
			if (value_inherit[e_value.TEXTURE_MATERIAL_OBJ] = other.id) 
				update_matrix = true
			
			if (value_inherit[e_value.TEXTURE_NORMAL_OBJ] = other.id) 
				update_matrix = true
		}
		
		with (obj_keyframe)
		{
			if (value[e_value.PATH_OBJ] = other.id)
				value[e_value.PATH_OBJ] = null
			
			if (value[e_value.IK_TARGET] = other.id)
				value[e_value.IK_TARGET] = null
			
			if (value[e_value.IK_TARGET_ANGLE] = other.id)
				value[e_value.IK_TARGET_ANGLE] = null
			
			if (value[e_value.ATTRACTOR] = other.id)
				value[e_value.ATTRACTOR] = null
			
			if (value[e_value.TEXTURE_OBJ] = other.id)
				value[e_value.TEXTURE_OBJ] = null
			
			if (value[e_value.TEXTURE_MATERIAL_OBJ] = other.id)
				value[e_value.TEXTURE_MATERIAL_OBJ] = null
			
			if (value[e_value.TEXTURE_NORMAL_OBJ] = other.id)
				value[e_value.TEXTURE_NORMAL_OBJ] = null
		}
		
		if (app.timeline_camera = id)
			app.timeline_camera = null
		
		while (ds_list_size(keyframe_list))
			with (keyframe_list[|0])
				instance_destroy()
		
		ds_list_destroy(keyframe_list)
		
		with (obj_particle)
			if (creator = other.id)
				instance_destroy()
		
		if (particle_list)
			ds_list_destroy(particle_list)
		
		if (temp = id)
		{
			if (type = e_tl_type.SPECIAL_BLOCK)
			{
				if (model_texture_name_map != null)	
					ds_map_destroy(model_texture_name_map)
				
				if (model_texture_material_name_map != null)	
					ds_map_destroy(model_texture_material_name_map)
				
				if (model_tex_normal_name_map != null)	
					ds_map_destroy(model_tex_normal_name_map)
				
				if (model_hide_list != null)
					ds_list_destroy(model_hide_list)
				
				if (model_color_name_map != null)	
					ds_map_destroy(model_color_name_map)
				
				if (model_color_map != null)	
					ds_map_destroy(model_color_map)
			}
			else if (type = e_tl_type.BLOCK)
				block_vbuffer_destroy()
		}
		
		if (model_shape_vbuffer_map != null && ds_map_size(model_shape_vbuffer_map) > 0)
		{
			model_shape_clear_cache(model_shape_cache_list, true)
			ds_map_destroy(model_shape_vbuffer_map)
		}
		
		if (model_shape_alpha_map != null)
			ds_map_destroy(model_shape_alpha_map)
		
		if (surface_exists(cam_surf))
			surface_free(cam_surf)
		
		if (surface_exists(cam_surf_tmp))
			surface_free(cam_surf_tmp)
		
		delete_ready = true
	}
}
