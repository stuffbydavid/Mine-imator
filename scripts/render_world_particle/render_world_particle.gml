/// render_world_particle()
/// @desc Renders the particle.

var temp, prevcolor, prevalpha;
temp = type.temp

prevcolor = shader_blend_color
prevalpha = shader_blend_alpha
shader_blend_color = color_multiply(prevcolor, color)
shader_blend_alpha *= alpha
render_set_uniform_color("uBlendColor", shader_blend_color, shader_blend_alpha)

if (temp != null)
{
	var scenery, rep, off;
	off = point3D(0, 0, 0)
	
	if (temp.block_repeat_enable)
		rep = temp.block_repeat
	else
		rep = vec3(1)
		
	switch (temp.type) // Rotation point
	{
		case e_temp_type.CHARACTER:
		case e_temp_type.SPECIAL_BLOCK:
			if (temp.model_file != null)
				off = point3D(0, 0, -(temp.model_file.bounds_parts_end[Z] - temp.model_file.bounds_parts_start[Z]) / 2)
			break
		
		case e_temp_type.SCENERY:
			scenery = temp.scenery
			if (scenery = null)
				break
			var displaysize = vec3_mul(vec3_mul(scenery.scenery_size, rep), vec3(block_size));
			off = vec3_mul(displaysize, vec3(-0.5))
			break
			
		case e_temp_type.BLOCK:
			off = point3D_mul(rep, -block_size / 2)
			break
		
		case e_temp_type.ITEM:
			off = point3D(-8, -0.5, 0)
			break
	}
	
	matrix_set(matrix_world, matrix_create(point3D_add(pos, off), rot, vec3(scale)))
	
	switch (temp.type)
	{
		case e_temp_type.CHARACTER:
		case e_temp_type.SPECIAL_BLOCK:
		{
			if (temp.model_file = null)
				break
			
			var res = temp.skin;
			if (!res.ready)
				res = mc_res
				
			render_world_model_file_parts(temp.model_file, temp.model_texture_name_map, temp.model_hide_list, res)
			break
		}
			
		case e_temp_type.SCENERY:
			if (scenery = null)
				break
			render_world_scenery(scenery, temp.block_tex, temp.block_repeat_enable, temp.block_repeat)
			break
			
		case e_temp_type.ITEM:
			render_world_item(temp.item_vbuffer, temp.item_3d, temp.item_face_camera, temp.item_bounce, temp.item_tex)
			break
		
		case e_temp_type.BLOCK:
			render_world_block(temp.block_vbuffer, rep, temp.block_tex) 
			break
		
		case e_temp_type.BODYPART:
			if (temp.model_part = null || temp.model_file = null)
				break
				
			var res = temp.skin;
			if (!res.ready)
				res = mc_res
							
			render_world_model_part(temp.model_part, temp.model_texture_name_map, res, 0, null)
			break
			
		case e_temp_type.TEXT:
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
		res = mc_res
	
	render_set_texture(res.particles_texture[type.sprite_tex_image])
	
	var xyang, zang, m;
	xyang = 90 + point_direction(pos[X], pos[Y], proj_from[X], proj_from[Y])
	zang = -point_zdirection(pos[X], pos[Y], pos[Z], proj_from[X], proj_from[Y], proj_from[Z])
	m = max(0, frame - min(type.sprite_frame_start, type.sprite_frame_end)) mod type.sprite_vbuffer_amount
	matrix_set(matrix_world, matrix_create(pos, vec3(zang, 0, xyang), vec3(scale)))
	
	vbuffer_render(type.sprite_vbuffer[m])
}

shader_blend_color = prevcolor
shader_blend_alpha = prevalpha