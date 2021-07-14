/// block_render_model_generate(model)
/// @arg model
/// @desc Generate triangles from the render model.

function block_render_model_generate(model)
{
	instance_activate_object(model)
	
	mc_builder.builder_chunk.bounding_box.set_vbuffer()
	
	with (model)
	{
		var offx, offy, offz;
		offx = offset_x + mc_builder.block_pos_x
		offy = offset_y + mc_builder.block_pos_y
		offz = offset_z + mc_builder.block_pos_z
		
		// Set brightness
		if (vertex_brightness = null)
			vertex_brightness = brightness
		
		// Apply noise
		var noiseoff = c_white;
		if (mc_builder.block_current != null)
		{
			if (app.project_render_noisy_grass_water && (mc_builder.block_current.name = "grass_block" || mc_builder.block_current.name = "grass"))
			{
				var noise = (1.0 - abs(simplex_lib(mc_builder.build_pos_x / 32, mc_builder.build_pos_y / 32)) * 0.15) * 255;
				noise -= (abs(simplex_lib(mc_builder.build_pos_x, mc_builder.build_pos_y)) * 0.075) * 255
				noiseoff = make_color_rgb(noise, noise, noise)
			}
		}
		
		// Generate elements
		for (var e = 0; e < element_amount; e++)
		{
			instance_activate_object(element[e])
			with (element[e])
			{
				var x1, x2, y1, y2, z1, z2, mat, color;
				x1 = from_x; y1 = from_y; z1 = from_z
				x2 = to_x;	 y2 = to_y;   z2 = to_z
				
				// Apply offset to transformation matrix if rotated
				if (rotated)
					mat = matrix_multiply(matrix, matrix_build(offx, offy, offz, 0, 0, 0, 1, 1, 1))
				
				// Otherwise simply add offset to shape
				else
				{
					mat = null
					x1 += offx; y1 += offy; z1 += offz
					x2 += offx; y2 += offy; z2 += offz
				}
				
				// X+
				if (face_render_xp && !block_render_model_generate_face_cull(e_dir.EAST))
				{
					if (mc_builder.block_color = null)
						color = face_texture_color_xp
					else
						color = mc_builder.block_color
					
					if (face_vbuffer_xp != null)
						vbuffer_current = face_vbuffer_xp
					else
						vbuffer_current = mc_builder.builder_chunk.vbuffer[face_depth_xp, face_block_vbuffer_xp]
					
					if (face_block_vbuffer_xp = e_block_vbuffer.GRASS)
						color = noiseoff
					
					vbuffer_add_triangle(x2, y2, z2, x2, y1, z2, x2, y1, z1, face_uv_xp_0_x, face_uv_xp_0_y, face_uv_xp_1_x, face_uv_xp_1_y, face_uv_xp_2_x, face_uv_xp_2_y, color, 1, false, mat)
					vbuffer_add_triangle(x2, y1, z1, x2, y2, z1, x2, y2, z2, face_uv_xp_2_x, face_uv_xp_2_y, face_uv_xp_3_x, face_uv_xp_3_y, face_uv_xp_0_x, face_uv_xp_0_y, color, 1, false, mat)
					
					mc_builder.builder_chunk.bounding_box.copy_vbuffer(false)
				}
				
				// X-
				if (face_render_xn && !block_render_model_generate_face_cull(e_dir.WEST))
				{
					if (mc_builder.block_color = null)
						color = face_texture_color_xn
					else
						color = mc_builder.block_color
					
					if (face_vbuffer_xn != null)
						vbuffer_current = face_vbuffer_xn
					else
						vbuffer_current = mc_builder.builder_chunk.vbuffer[face_depth_xn, face_block_vbuffer_xn]
					
					if (face_block_vbuffer_xn = e_block_vbuffer.GRASS)
						color = noiseoff
					
					vbuffer_add_triangle(x1, y1, z2, x1, y2, z2, x1, y2, z1, face_uv_xn_0_x, face_uv_xn_0_y, face_uv_xn_1_x, face_uv_xn_1_y, face_uv_xn_2_x, face_uv_xn_2_y, color, 1, false, mat)
					vbuffer_add_triangle(x1, y2, z1, x1, y1, z1, x1, y1, z2, face_uv_xn_2_x, face_uv_xn_2_y, face_uv_xn_3_x, face_uv_xn_3_y, face_uv_xn_0_x, face_uv_xn_0_y, color, 1, false, mat)
					
					mc_builder.builder_chunk.bounding_box.copy_vbuffer(false)
				}
				
				// Y+
				if (face_render_yp && !block_render_model_generate_face_cull(e_dir.SOUTH))
				{
					if (mc_builder.block_color = null)
						color = face_texture_color_yp
					else
						color = mc_builder.block_color
					
					if (face_vbuffer_yp != null)
						vbuffer_current = face_vbuffer_yp
					else
						vbuffer_current = mc_builder.builder_chunk.vbuffer[face_depth_yp, face_block_vbuffer_yp]
					
					if (face_block_vbuffer_yp = e_block_vbuffer.GRASS)
						color = noiseoff
					
					vbuffer_add_triangle(x1, y2, z2, x2, y2, z2, x2, y2, z1, face_uv_yp_0_x, face_uv_yp_0_y, face_uv_yp_1_x, face_uv_yp_1_y, face_uv_yp_2_x, face_uv_yp_2_y, color, 1, false, mat)
					vbuffer_add_triangle(x2, y2, z1, x1, y2, z1, x1, y2, z2, face_uv_yp_2_x, face_uv_yp_2_y, face_uv_yp_3_x, face_uv_yp_3_y, face_uv_yp_0_x, face_uv_yp_0_y, color, 1, false, mat)
					
					mc_builder.builder_chunk.bounding_box.copy_vbuffer(false)
				}
				
				// Y-
				if (face_render_yn && !block_render_model_generate_face_cull(e_dir.NORTH))
				{
					if (mc_builder.block_color = null)
						color = face_texture_color_yn
					else
						color = mc_builder.block_color
					
					if (face_vbuffer_yn != null)
						vbuffer_current = face_vbuffer_yn
					else
						vbuffer_current = mc_builder.builder_chunk.vbuffer[face_depth_yn, face_block_vbuffer_yn]
					
					if (face_block_vbuffer_yn = e_block_vbuffer.GRASS)
						color = noiseoff
					
					vbuffer_add_triangle(x2, y1, z2, x1, y1, z2, x1, y1, z1, face_uv_yn_0_x, face_uv_yn_0_y, face_uv_yn_1_x, face_uv_yn_1_y, face_uv_yn_2_x, face_uv_yn_2_y, color, 1, false, mat)
					vbuffer_add_triangle(x1, y1, z1, x2, y1, z1, x2, y1, z2, face_uv_yn_2_x, face_uv_yn_2_y, face_uv_yn_3_x, face_uv_yn_3_y, face_uv_yn_0_x, face_uv_yn_0_y, color, 1, false, mat)
					
					mc_builder.builder_chunk.bounding_box.copy_vbuffer(false)
				}
				
				// Z+
				if (face_render_zp && !block_render_model_generate_face_cull(e_dir.UP))
				{
					if (mc_builder.block_color = null)
						color = face_texture_color_zp
					else
						color = mc_builder.block_color
					
					if (face_vbuffer_zp != null)
						vbuffer_current = face_vbuffer_zp
					else
						vbuffer_current = mc_builder.builder_chunk.vbuffer[face_depth_zp, face_block_vbuffer_zp]
					
					if (face_block_vbuffer_zp = e_block_vbuffer.GRASS)
						color = noiseoff
					
					vbuffer_add_triangle(x1, y1, z2, x2, y1, z2, x2, y2, z2, face_uv_zp_0_x, face_uv_zp_0_y, face_uv_zp_1_x, face_uv_zp_1_y, face_uv_zp_2_x, face_uv_zp_2_y, color, 1, false, mat)
					vbuffer_add_triangle(x2, y2, z2, x1, y2, z2, x1, y1, z2, face_uv_zp_2_x, face_uv_zp_2_y, face_uv_zp_3_x, face_uv_zp_3_y, face_uv_zp_0_x, face_uv_zp_0_y, color, 1, false, mat)
					
					mc_builder.builder_chunk.bounding_box.copy_vbuffer(false)
				}
				
				// Z-
				if (face_render_zn && !block_render_model_generate_face_cull(e_dir.DOWN))
				{
					if (mc_builder.block_color = null)
						color = face_texture_color_zn
					else
						color = mc_builder.block_color
					
					if (face_vbuffer_zn != null)
						vbuffer_current = face_vbuffer_zn
					else
						vbuffer_current = mc_builder.builder_chunk.vbuffer[face_depth_zn, face_block_vbuffer_zn]
					
					if (face_block_vbuffer_zn = e_block_vbuffer.GRASS)
						color = noiseoff
					
					vbuffer_add_triangle(x1, y2, z1, x2, y2, z1, x2, y1, z1, face_uv_zn_0_x, face_uv_zn_0_y, face_uv_zn_1_x, face_uv_zn_1_y, face_uv_zn_2_x, face_uv_zn_2_y, color, 1, false, mat)
					vbuffer_add_triangle(x2, y1, z1, x1, y1, z1, x1, y2, z1, face_uv_zn_2_x, face_uv_zn_2_y, face_uv_zn_3_x, face_uv_zn_3_y, face_uv_zn_0_x, face_uv_zn_0_y, color, 1, false, mat)
					
					mc_builder.builder_chunk.bounding_box.copy_vbuffer(false)
				}
			}
			instance_deactivate_object(element[e])
		}
	}
	
	instance_deactivate_object(model)
}
