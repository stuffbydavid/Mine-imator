/// block_render_model_generate(model)
/// @arg model
/// @desc Generate triangles from the render model.

function block_render_model_generate(model)
{
	instance_activate_object(model)
	
	var offx, offy, offz;
	offx = model.offset_x + block_pos_x
	offy = model.offset_y + block_pos_y
	offz = model.offset_z + block_pos_z
		
	// Set emissive
	if (block_vertex_emissive = null)
		block_vertex_emissive = model.emissive
		
	// Generate elements
	for (var e = 0; e < model.element_amount; e++)
	{
		var el = model.element[e];
		instance_activate_object(el)
		
		var x1, x2, y1, y2, z1, z2, mat;
		x1 = el.from_x; y1 = el.from_y; z1 = el.from_z
		x2 = el.to_x;   y2 = el.to_y;   z2 = el.to_z
				
		// Apply offset to transformation matrix if rotated
		if (el.rotated)
			mat = matrix_multiply(el.matrix, matrix_build(offx, offy, offz, 0, 0, 0, 1, 1, 1))
				
		// Otherwise simply add offset to shape
		else
		{
			mat = null
			x1 += offx; y1 += offy; z1 += offz
			x2 += offx; y2 += offy; z2 += offz
		}
				
		// X+
		if (el.face_render_xp && !block_render_model_generate_face_cull(model, el, e_dir.EAST))
		{
			if (block_color = null)
				block_vertex_rgb = el.face_texture_color_xp
			else
				block_vertex_rgb = block_color
					
			if (el.face_vbuffer_xp != null)
				block_vbuffer_current = el.face_vbuffer_xp
			else
				block_vbuffer_current = mc_builder.vbuffer[el.face_depth_xp, el.face_block_vbuffer_xp]
					
			builder_add_face(x2, y2, z2, x2, y1, z2, x2, y1, z1, x2, y2, z1, el.face_uv_xp_0_x, el.face_uv_xp_0_y, el.face_uv_xp_1_x, el.face_uv_xp_1_y, el.face_uv_xp_2_x, el.face_uv_xp_2_y, el.face_uv_xp_3_x, el.face_uv_xp_3_y, mat)
		}
				
		// X-
		if (el.face_render_xn && !block_render_model_generate_face_cull(model, el, e_dir.WEST))
		{
			if (block_color = null)
				block_vertex_rgb = el.face_texture_color_xn
			else
				block_vertex_rgb = block_color
					
			if (el.face_vbuffer_xn != null)
				block_vbuffer_current = el.face_vbuffer_xn
			else
				block_vbuffer_current = mc_builder.vbuffer[el.face_depth_xn, el.face_block_vbuffer_xn]
				
			builder_add_face(x1, y1, z2, x1, y2, z2, x1, y2, z1, x1, y1, z1, el.face_uv_xn_0_x, el.face_uv_xn_0_y, el.face_uv_xn_1_x, el.face_uv_xn_1_y, el.face_uv_xn_2_x, el.face_uv_xn_2_y, el.face_uv_xn_3_x, el.face_uv_xn_3_y, mat)
		}
				
		// Y+
		if (el.face_render_yp && !block_render_model_generate_face_cull(model, el, e_dir.SOUTH))
		{
			if (block_color = null)
				block_vertex_rgb = el.face_texture_color_yp
			else
				block_vertex_rgb = block_color
					
			if (el.face_vbuffer_yp != null)
				block_vbuffer_current = el.face_vbuffer_yp
			else
				block_vbuffer_current = mc_builder.vbuffer[el.face_depth_yp, el.face_block_vbuffer_yp]
						
			builder_add_face(x1, y2, z2, x2, y2, z2, x2, y2, z1, x1, y2, z1, el.face_uv_yp_0_x, el.face_uv_yp_0_y, el.face_uv_yp_1_x, el.face_uv_yp_1_y, el.face_uv_yp_2_x, el.face_uv_yp_2_y, el.face_uv_yp_3_x, el.face_uv_yp_3_y, mat)
		}
				
		// Y-
		if (el.face_render_yn && !block_render_model_generate_face_cull(model, el, e_dir.NORTH))
		{
			if (block_color = null)
				block_vertex_rgb = el.face_texture_color_yn
			else
				block_vertex_rgb = block_color
					
			if (el.face_vbuffer_yn != null)
				block_vbuffer_current = el.face_vbuffer_yn
			else
				block_vbuffer_current = mc_builder.vbuffer[el.face_depth_yn, el.face_block_vbuffer_yn]
						
			builder_add_face(x2, y1, z2, x1, y1, z2, x1, y1, z1, x2, y1, z1, el.face_uv_yn_0_x, el.face_uv_yn_0_y, el.face_uv_yn_1_x, el.face_uv_yn_1_y, el.face_uv_yn_2_x, el.face_uv_yn_2_y, el.face_uv_yn_3_x, el.face_uv_yn_3_y, mat)
		}
				
		// Z+
		if (el.face_render_zp && !block_render_model_generate_face_cull(model, el, e_dir.UP))
		{
			if (block_color = null)
				block_vertex_rgb = el.face_texture_color_zp
			else
				block_vertex_rgb = block_color
					
			if (el.face_vbuffer_zp != null)
				block_vbuffer_current = el.face_vbuffer_zp
			else
				block_vbuffer_current = mc_builder.vbuffer[el.face_depth_zp, el.face_block_vbuffer_zp]
					
			builder_add_face(x1, y1, z2, x2, y1, z2, x2, y2, z2, x1, y2, z2, el.face_uv_zp_0_x, el.face_uv_zp_0_y, el.face_uv_zp_1_x, el.face_uv_zp_1_y, el.face_uv_zp_2_x, el.face_uv_zp_2_y, el.face_uv_zp_3_x, el.face_uv_zp_3_y, mat)
		}
				
		// Z-
		if (el.face_render_zn && !block_render_model_generate_face_cull(model, el, e_dir.DOWN))
		{
			if (block_color = null)
				block_vertex_rgb = el.face_texture_color_zn
			else
				block_vertex_rgb = block_color
					
			if (el.face_vbuffer_zn != null)
				block_vbuffer_current = el.face_vbuffer_zn
			else
				block_vbuffer_current = mc_builder.vbuffer[el.face_depth_zn, el.face_block_vbuffer_zn]
						
			builder_add_face(x1, y2, z1, x2, y2, z1, x2, y1, z1, x1, y1, z1, el.face_uv_zn_0_x, el.face_uv_zn_0_y, el.face_uv_zn_1_x, el.face_uv_zn_1_y, el.face_uv_zn_2_x, el.face_uv_zn_2_y, el.face_uv_zn_3_x, el.face_uv_zn_3_y, mat)
		}
				
		block_vertex_rgb = c_white

		instance_deactivate_object(model.element[e])
	}
	
	instance_deactivate_object(model)
}
