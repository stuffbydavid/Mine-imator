/// particle_draw()
/// Draws the particle.
// TODO!
var temp, prevalpha, prevcolor;
temp = type.temp

prevalpha = shader_alpha
prevcolor = shader_blend_color
shader_blend_color = color
shader_alpha *= alpha

if (temp)
{
	var sch, repx, repy, repz;
	repx = (temp.repeat_x - 1) * temp.repeat_toggle + 1
	repy = (temp.repeat_y - 1) * temp.repeat_toggle + 1
	repz = (temp.repeat_z - 1) * temp.repeat_toggle + 1
	matrix_reset_offset()
	
	switch (temp.type) // Rotation point
	{
		case "char":
		case "spblock":
			//matrix_offset = point3D(0, 0, -temp.char_model.height / 2)
			break
		
		case "scenery":
			/*sch = temp.scenery
			if (!sch)
				break
			matrix_offset = point3D(-sch.sch_xsize * repx * 8, -sch.sch_ysize * repy * 8, -sch.sch_zsize * repz * 8)*/
			break
			
		case "block":
			matrix_offset = point3D(-repx * 8, -repy * 8, -repz * 8)
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
			/*var char, res, mat;
			char = temp.char_model
			res = temp.char_skin
			if (!res.ready)
				res = res_def
			shader_texture = res.mob_texture[char.index]
			shader_use()
			mat = matrix_get(matrix_world)
			
			for (var p = 0; p < char.part_amount; p++)
			{
				if (char.part_vbuffer[p] = null)
					continue
				matrix_set(matrix_world, mat)
				matrix_add_offset()
				matrix_world_multiply_pre(char.part_matrix[p])
				vbuffer_render(char.part_vbuffer[p])
				if (char.part_hasbend[p]) // Draw bend half
				{
					matrix_set(matrix_world, mat)
					matrix_add_offset()
					matrix_world_multiply_pre(char.part_matrix_bend[p])
					vbuffer_render(char.part_bendvbuffer[p])
				}
			}*/
			break
			
		case "scenery":
			if (!sch)
				break
			render_world_scenery(sch, temp.block_tex, temp.repeat_toggle, repx, repy, repz)
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
