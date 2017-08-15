/// particle_draw()
/// @desc Draws the particle.

var temp, prevalpha, prevcolor;
temp = type.temp

prevalpha = shader_alpha
prevcolor = shader_blend_color
shader_blend_color = color
shader_alpha *= alpha

if (temp)
{
	var scenery, rep;
	
	if (temp.block_repeat_enable)
		rep = temp.block_repeat
	else
		rep = vec3(1)
		
	matrix_reset_offset()
	
	switch (temp.type) // Rotation point
	{
		case "char":
		case "spblock":
			matrix_offset = point3D(0, 0, -(temp.char_model.bounds_end[Z] - temp.char_model.bounds_start[Z]) / 2)
			break
		
		case "scenery":
			scenery = temp.scenery
			if (!scenery)
				break
			var displaysize = vec3_mul(vec3_mul(scenery.scenery_size, rep), point3D(block_size, block_size, block_size));
			matrix_offset = vec3_mul(displaysize, vec3(-0.5))
			break
			
		case "block":
			matrix_offset = point3D_mul(rep, -block_size / 2)
			break
		
		case "item":
			matrix_offset = point3D(-8, -0.5, 0)
			break
	}
	
	matrix_set(matrix_world, matrix_create(pos, rot, vec3(scale)))
	
	switch (temp.type)
	{
		case "char":
		case "spblock":
		{
			if (temp.char_model_file = null)
				break
			
			var res = temp.char_skin;
			if (!res.ready)
				res = res_def
				
			render_world_model_file_parts(temp.char_model_file, temp.char_model_texture_name, res)
			break
		}
			
		case "scenery":
			if (!scenery)
				break
			render_world_scenery(scenery, temp.block_tex, temp.block_repeat_enable, temp.block_repeat)
			break
			
		case "item":
			render_world_item(temp.item_vbuffer, temp.item_bounce, temp.item_face_camera, temp.item_tex)
			break
		
		case "block":
			render_world_block(temp.block_vbuffer, temp.block_tex) 
			break
		
		case "bodypart":
			/*var char, bodypart, res;
			char = temp.char_model
			bodypart = temp.char_bodypart
			if (char.part_vbuffer[bodypart] = null)
				break
				
			res = temp.char_skin
			if (!res.ready)
				res = res_def
			
			shader_texture = res.mob_texture[char.index]
			shader_use()
			vbuffer_render(char.part_vbuffer[bodypart])
			if (char.part_hasbend[bodypart])
			{ // Draw bend half
				matrix_world_multiply_pre(tl_bend_matrix(0, char, bodypart))
				vbuffer_render(char.part_bendvbuffer[bodypart])
			}*/
			break
			
		case "text":
			render_world_text(type.text_vbuffer, type.text_texture, temp.text_face_camera, temp.text_font)
			break
		
		default: // Shapes
			var tex;
			with (temp)
				tex = temp_get_shape_tex(temp_get_shape_texobj(null))
			render_world_shape(temp.type, temp.shape_vbuffer, temp.shape_face_camera, tex)
			break
	}
}
else // Sprite
{
	var res = type.sprite_tex;
	if (!res.ready)
		res = res_def
	
	shader_texture = res.particles_texture[type.sprite_tex_image]
	shader_use()
	
	var xyang, zang, m;
	xyang = 90 + point_direction(pos[X], pos[Y], proj_from[X], proj_from[Y])
	zang = -point_zdirection(pos[X], pos[Y], pos[Z], proj_from[X], proj_from[Y], proj_from[Z])
	m = max(0, frame - min(type.sprite_frame_start, type.sprite_frame_end)) mod type.sprite_vbuffers
	matrix_set(matrix_world, matrix_create(pos, vec3(zang, 0, xyang), vec3(scale)))
	
	vbuffer_render(type.sprite_vbuffer[m])
}

shader_alpha = prevalpha
shader_blend_color = prevcolor
