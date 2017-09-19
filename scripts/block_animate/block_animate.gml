/// block_animate(creator, root)
/// @arg creator
/// @arg root
/// @arg size

var creator, root, tltype;
creator = argument0
root = argument1

// Create timeline
with (new(obj_timeline))
{
	temp = id
	
	// Special block
	if (other.model_name != "")
	{
		type = "spblock"
		
		model_name = other.model_name
		model_state = other.model_state
		model_state_map = null
		model_file = null
		model_texture_name_map = null
		skin = res_def
		
		temp_update_model_state_map()
		temp_update_model()
		
		// Add model parts
		part_list = ds_list_create()
		if (model_file != null)
			for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
				ds_list_add(part_list, tl_new_part(model_file.file_part_list[|p]))
			
		tl_update_part_list(model_file, id)
	}
	
	// Block
	else
	{
		type = "block"
		
		block_name = other.block.name
		block_state = other.block.default_state
		block_state_map = null
		block_tex = res_def
		block_repeat_enable = false
		block_repeat = vec3(1)
		block_vbuffer_reset()
		
		temp_update_block_state_map()
		temp_update_block()
		
		texture_filtering = true
	}
	
	rot_point_custom = true
	rot_point = array_copy_1d(other.rot_point)
		
	// Rotate by 90 degrees for legacy support
	var pos = point3D_mul_matrix(other.position, matrix_create(point3D(0, creator.scenery.scenery_size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)))
	value_default[e_value.POS_X] = snap(pos[X], 0.5)
	value_default[e_value.POS_Y] = snap(pos[Y], 0.5)
	value_default[e_value.POS_Z] = snap(pos[Z], 0.5)
	value_default[e_value.ROT_X] = other.rotation[X]
	value_default[e_value.ROT_Y] = other.rotation[Y]
	value_default[e_value.ROT_Z] = other.rotation[Z] + 90
	
	// Set to be a part of the schematic
	part_of = root
	ds_list_add(root.part_list, id)
	tl_set_parent(root)
	
	tl_update()
	tl_update_values()
	
	// Add text
	if (other.has_text)
	{
		var text, textpos;
		text = other.text
		textpos = other.text_position
		part_list = ds_list_create()
		
		with (new(obj_timeline))
		{
			type = "text"
			temp = id
			
			id.text = text
			text_font = res_def
			text_3d = false
			text_face_camera = false
			
			value_default[e_value.POS_X] = textpos[X]
			value_default[e_value.POS_Y] = textpos[Y]
			value_default[e_value.POS_Z] = textpos[Z]
			value_default[e_value.SCA_X] = 0.175
			value_default[e_value.SCA_Y] = 0.175
			value_default[e_value.SCA_Z] = 0.175
			value_default[e_value.RGB_MUL] = c_black
			
			// Set parent to other timeline, and to be part of the schematic
			part_of = root
			ds_list_add(root.part_list, id)
			tl_set_parent(other.id)
			
			tl_update()
			tl_update_values()
		}
	}
}