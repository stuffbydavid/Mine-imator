/// block_render_model_generate(model)
/// @arg models
/// @desc Generate triangles from the render model.

var model = argument0;

with (model)
{
	var offx, offy, offz;
	offx = offset_x + mc_builder.block_pos_x
	offy = offset_y + mc_builder.block_pos_y
	offz = offset_z + mc_builder.block_pos_z
	
	// Set brightness
	if (vertex_brightness = null)
		vertex_brightness = brightness
	
	// Generate elements
	for (var e = 0; e < element_amount; e++)
	{
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
				
				vbuffer_current = mc_builder.vbuffer[face_depth_xp, face_vbuffer_xp]
				vbuffer_add_triangle(x2, y2, z2, x2, y1, z2, x2, y1, z1, face_uv_xp_0_x, face_uv_xp_0_y, face_uv_xp_1_x, face_uv_xp_1_y, face_uv_xp_2_x, face_uv_xp_2_y, color, 1, mat)
				vbuffer_add_triangle(x2, y1, z1, x2, y2, z1, x2, y2, z2, face_uv_xp_2_x, face_uv_xp_2_y, face_uv_xp_3_x, face_uv_xp_3_y, face_uv_xp_0_x, face_uv_xp_0_y, color, 1, mat)
			}
			
			// X-
			if (face_render_xn && !block_render_model_generate_face_cull(e_dir.WEST))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_xn
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_xn, face_vbuffer_xn]
				vbuffer_add_triangle(x1, y1, z2, x1, y2, z2, x1, y2, z1, face_uv_xn_0_x, face_uv_xn_0_y, face_uv_xn_1_x, face_uv_xn_1_y, face_uv_xn_2_x, face_uv_xn_2_y, color, 1, mat)
				vbuffer_add_triangle(x1, y2, z1, x1, y1, z1, x1, y1, z2, face_uv_xn_2_x, face_uv_xn_2_y, face_uv_xn_3_x, face_uv_xn_3_y, face_uv_xn_0_x, face_uv_xn_0_y, color, 1, mat)
			}
			
			// Y+
			if (face_render_yp && !block_render_model_generate_face_cull(e_dir.SOUTH))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_yp
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_yp, face_vbuffer_yp]
				vbuffer_add_triangle(x1, y2, z2, x2, y2, z2, x2, y2, z1, face_uv_yp_0_x, face_uv_yp_0_y, face_uv_yp_1_x, face_uv_yp_1_y, face_uv_yp_2_x, face_uv_yp_2_y, color, 1, mat)
				vbuffer_add_triangle(x2, y2, z1, x1, y2, z1, x1, y2, z2, face_uv_yp_2_x, face_uv_yp_2_y, face_uv_yp_3_x, face_uv_yp_3_y, face_uv_yp_0_x, face_uv_yp_0_y, color, 1, mat)
			}
			
			// Y-
			if (face_render_yn && !block_render_model_generate_face_cull(e_dir.NORTH))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_yn
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_yn, face_vbuffer_yn]
				vbuffer_add_triangle(x2, y1, z2, x1, y1, z2, x1, y1, z1, face_uv_yn_0_x, face_uv_yn_0_y, face_uv_yn_1_x, face_uv_yn_1_y, face_uv_yn_2_x, face_uv_yn_2_y, color, 1, mat)
				vbuffer_add_triangle(x1, y1, z1, x2, y1, z1, x2, y1, z2, face_uv_yn_2_x, face_uv_yn_2_y, face_uv_yn_3_x, face_uv_yn_3_y, face_uv_yn_0_x, face_uv_yn_0_y, color, 1, mat)
			}
			
			// Z+
			if (face_render_zp && !block_render_model_generate_face_cull(e_dir.UP))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_zp
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_zp, face_vbuffer_zp]
				vbuffer_add_triangle(x1, y1, z2, x2, y1, z2, x2, y2, z2, face_uv_zp_0_x, face_uv_zp_0_y, face_uv_zp_1_x, face_uv_zp_1_y, face_uv_zp_2_x, face_uv_zp_2_y, color, 1, mat)
				vbuffer_add_triangle(x2, y2, z2, x1, y2, z2, x1, y1, z2, face_uv_zp_2_x, face_uv_zp_2_y, face_uv_zp_3_x, face_uv_zp_3_y, face_uv_zp_0_x, face_uv_zp_0_y, color, 1, mat)
			}
			
			// Z-
			if (face_render_zn && !block_render_model_generate_face_cull(e_dir.DOWN))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_zn
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_zn, face_vbuffer_zn]
				vbuffer_add_triangle(x1, y2, z1, x2, y2, z1, x2, y1, z1, face_uv_zn_0_x, face_uv_zn_0_y, face_uv_zn_1_x, face_uv_zn_1_y, face_uv_zn_2_x, face_uv_zn_2_y, color, 1, mat)
				vbuffer_add_triangle(x2, y1, z1, x1, y1, z1, x1, y2, z1, face_uv_zn_2_x, face_uv_zn_2_y, face_uv_zn_3_x, face_uv_zn_3_y, face_uv_zn_0_x, face_uv_zn_0_y, color, 1, mat)
			}
		}
	}
}