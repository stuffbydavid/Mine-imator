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
				vbuffer_add_triangle(x2, y2, z2, x2, y1, z2, x2, y1, z1, face_uv_xp_0_x, face_uv_xp_0_y, face_uv_xp_1_x, face_uv_xp_1_y, face_uv_xp_2_x, face_uv_xp_2_y, color, mat)
				vbuffer_add_triangle(x2, y1, z1, x2, y2, z1, x2, y2, z2, face_uv_xp_2_x, face_uv_xp_2_y, face_uv_xp_3_x, face_uv_xp_3_y, face_uv_xp_0_x, face_uv_xp_0_y, color, mat)
			}
			
			// X-
			if (face_render_xn && !block_render_model_generate_face_cull(e_dir.WEST))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_xn
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_xn, face_vbuffer_xn]
				vbuffer_add_triangle(x1, y1, z2, x1, y2, z2, x1, y2, z1, face_uv_xn_0_x, face_uv_xn_0_y, face_uv_xn_1_x, face_uv_xn_1_y, face_uv_xn_2_x, face_uv_xn_2_y, color, mat)
				vbuffer_add_triangle(x1, y2, z1, x1, y1, z1, x1, y1, z2, face_uv_xn_2_x, face_uv_xn_2_y, face_uv_xn_3_x, face_uv_xn_3_y, face_uv_xn_0_x, face_uv_xn_0_y, color, mat)
			}
			
			// Y+
			if (face_render_yp && !block_render_model_generate_face_cull(e_dir.SOUTH))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_yp
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_yp, face_vbuffer_yp]
				vbuffer_add_triangle(x1, y2, z2, x2, y2, z2, x2, y2, z1, face_uv_yp_0_x, face_uv_yp_0_y, face_uv_yp_1_x, face_uv_yp_1_y, face_uv_yp_2_x, face_uv_yp_2_y, color, mat)
				vbuffer_add_triangle(x2, y2, z1, x1, y2, z1, x1, y2, z2, face_uv_yp_2_x, face_uv_yp_2_y, face_uv_yp_3_x, face_uv_yp_3_y, face_uv_yp_0_x, face_uv_yp_0_y, color, mat)
			}
			
			// Y-
			if (face_render_yn && !block_render_model_generate_face_cull(e_dir.NORTH))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_yn
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_yn, face_vbuffer_yn]
				vbuffer_add_triangle(x2, y1, z2, x1, y1, z2, x1, y1, z1, face_uv_yn_0_x, face_uv_yn_0_y, face_uv_yn_1_x, face_uv_yn_1_y, face_uv_yn_2_x, face_uv_yn_2_y, color, mat)
				vbuffer_add_triangle(x1, y1, z1, x2, y1, z1, x2, y1, z2, face_uv_yn_2_x, face_uv_yn_2_y, face_uv_yn_3_x, face_uv_yn_3_y, face_uv_yn_0_x, face_uv_yn_0_y, color, mat)
			}
			
			// Z+
			if (face_render_zp && !block_render_model_generate_face_cull(e_dir.UP))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_zp
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_zp, face_vbuffer_zp]
				vbuffer_add_triangle(x1, y1, z2, x2, y1, z2, x2, y2, z2, face_uv_zp_0_x, face_uv_zp_0_y, face_uv_zp_1_x, face_uv_zp_1_y, face_uv_zp_2_x, face_uv_zp_2_y, color, mat)
				vbuffer_add_triangle(x2, y2, z2, x1, y2, z2, x1, y1, z2, face_uv_zp_2_x, face_uv_zp_2_y, face_uv_zp_3_x, face_uv_zp_3_y, face_uv_zp_0_x, face_uv_zp_0_y, color, mat)
			}
			
			// Z-
			if (face_render_zn && !block_render_model_generate_face_cull(e_dir.DOWN))
			{
				if (mc_builder.block_color = null)
					color = face_texture_color_zn
				else
					color = mc_builder.block_color
				
				vbuffer_current = mc_builder.vbuffer[face_depth_zn, face_vbuffer_zn]
				vbuffer_add_triangle(x1, y2, z1, x2, y2, z1, x2, y1, z1, face_uv_zn_0_x, face_uv_zn_0_y, face_uv_zn_1_x, face_uv_zn_1_y, face_uv_zn_2_x, face_uv_zn_2_y, color, mat)
				vbuffer_add_triangle(x2, y1, z1, x1, y1, z1, x1, y2, z1, face_uv_zn_2_x, face_uv_zn_2_y, face_uv_zn_3_x, face_uv_zn_3_y, face_uv_zn_0_x, face_uv_zn_0_y, color, mat)
			}
		}
	}
}
/*
for (var m = 0; m < modelslen; m++)
{
	with (models[m])
	{
		var off = point3D_add(mc_builder.block_pos, offset);
		
		// Set brightness
		vertex_brightness = brightness
		
		// Create elements
		for (var e = 0; e < element_amount; e++)
		{
			with (element[e])
			{
				var x1, x2, y1, y2, z1, z2;
				var p1, p2, p3, p4;
				var mat;
				
				x1 = from[X];	y1 = from[Y]; z1 = from[Z]
				x2 = to[X];		y2 = to[Y];   z2 = to[Z]
				
				//if (matrix != null)
				//{
					mat = array_copy_1d(matrix);
					mat[MAT_X] += off[X]
					mat[MAT_Y] += off[Y]
					mat[MAT_Z] += off[Z]
				}
				
				// Simply add to shape
				else
				{
					mat = null
					x1 += off[X]; y1 += off[Y]; z1 += off[Z]
					x2 += off[X]; y2 += off[Y]; z2 += off[Z]
				}
		
				// Create faces
				for (var f = 0; f < e_dir.amount; f++)
				{
					if (!face_render[f])
						continue
			
					// Check culling
					var culldir = face_rot_cullface[f];
					if (culldir != null)
					{
						var cullmodels, cull;
						cullmodels = mc_builder.block_render_models_dir[culldir]
						cull = false
					
						// Check with each model
						for (var cm = 0; cm < array_length_1d(cullmodels); cm++)
						{
							// Check elements of next block
							for (var ce = 0; ce < cullmodels[cm].element_amount; ce++)
							{
								var elem = cullmodels[cm].element[ce];
						
								if (elem.rotated)
									continue
						
								// Only check faces that are touching the edge and don't have a higher depth (transparency)
								switch (culldir)
								{
									case e_dir.EAST:
										if (elem.rot_face_render[e_dir.WEST] && elem.rot_from[X] = 0 && elem.rot_face_depth[e_dir.WEST] <= face_depth[f])
										{
											cull = (rot_from[Y] >= elem.rot_from[Y] && rot_from[Z] >= elem.rot_from[Z] &&
													rot_to[Y]	<= elem.rot_to[Y]	&& rot_to[Z]   <= elem.rot_to[Z])
										}
										break
							
									case e_dir.WEST:
										if (elem.rot_face_render[e_dir.EAST] && elem.rot_to[X] = block_size && elem.rot_face_depth[e_dir.EAST] <= face_depth[f])
										{
											cull = (rot_from[Y] >= elem.rot_from[Y] && rot_from[Z] >= elem.rot_from[Z] &&
													rot_to[Y]	<= elem.rot_to[Y]	&& rot_to[Z]   <= elem.rot_to[Z])
										}
										break
								
									case e_dir.SOUTH:
										if (elem.rot_face_render[e_dir.NORTH] && elem.rot_from[Y] = 0 && elem.rot_face_depth[e_dir.NORTH] <= face_depth[f])
										{
											cull = (rot_from[X] >= elem.rot_from[X] && rot_from[Z] >= elem.rot_from[Z] &&
													rot_to[X]	<= elem.rot_to[X]	&& rot_to[Z]   <= elem.rot_to[Z])
										}
										break
								
									case e_dir.NORTH:
										if (elem.rot_face_render[e_dir.SOUTH] && elem.rot_to[Y] = block_size && elem.rot_face_depth[e_dir.SOUTH] <= face_depth[f])
										{
											cull = (rot_from[X] >= elem.rot_from[X] && rot_from[Z] >= elem.rot_from[Z] &&
													rot_to[X]	<= elem.rot_to[X]	&& rot_to[Z]   <= elem.rot_to[Z])
										}
										break
								
									case e_dir.UP:
										if (elem.rot_face_render[e_dir.DOWN] && elem.rot_from[Z] = 0 && elem.rot_face_depth[e_dir.DOWN] <= face_depth[f])
										{
											cull = (rot_from[X] >= elem.rot_from[X] && rot_from[Y] >= elem.rot_from[Y] &&
													rot_to[X]	<= elem.rot_to[X]	&& rot_to[Y]   <= elem.rot_to[Y])
										}
										break
								
									case e_dir.DOWN:
										if (elem.rot_face_render[e_dir.UP] && elem.rot_to[Z] = block_size && elem.rot_face_depth[e_dir.UP] <= face_depth[f])
										{
											cull = (rot_from[X] >= elem.rot_from[X] && rot_from[Y] >= elem.rot_from[Y] &&
													rot_to[X]	<= elem.rot_to[X]	&& rot_to[Y]   <= elem.rot_to[Y])
										}
										break
								}
								if (cull)
									break
							}
							if (cull)
								break
						}
						if (cull)
							continue
					}
			
					// Set corners
					switch (f)
					{
						case e_dir.EAST:
							p1 = point3D(x2, y2, z2)
							p2 = point3D(x2, y1, z2)
							p3 = point3D(x2, y1, z1)
							p4 = point3D(x2, y2, z1)
							break
					
						case e_dir.WEST:
							p1 = point3D(x1, y1, z2)
							p2 = point3D(x1, y2, z2)
							p3 = point3D(x1, y2, z1)
							p4 = point3D(x1, y1, z1)
							break
					
						case e_dir.SOUTH:
							p1 = point3D(x1, y2, z2)
							p2 = point3D(x2, y2, z2)
							p3 = point3D(x2, y2, z1)
							p4 = point3D(x1, y2, z1)
							break
					
						case e_dir.NORTH:
							p1 = point3D(x2, y1, z2)
							p2 = point3D(x1, y1, z2)
							p3 = point3D(x1, y1, z1)
							p4 = point3D(x2, y1, z1)
							break
					
						case e_dir.UP:
							p1 = point3D(x1, y1, z2)
							p2 = point3D(x2, y1, z2)
							p3 = point3D(x2, y2, z2)
							p4 = point3D(x1, y2, z2)
							break
					
						case e_dir.DOWN:
							p1 = point3D(x1, y2, z1)
							p2 = point3D(x2, y2, z1)
							p3 = point3D(x2, y1, z1)
							p4 = point3D(x1, y1, z1)
							break
					}
			
					// Get color
					var color = face_texture_color[f];
					if (mc_builder.block_color != null)
						color = mc_builder.block_color
				
					// Add two triangles for each face
					vbuffer_current = mc_builder.vbuffer[face_depth[f], face_vbuffer[f]]
					vbuffer_add_triangle(p1, p2, p3, face_uv[f, 0], face_uv[f, 1], face_uv[f, 2], null, color, mat)
					vbuffer_add_triangle(p3, p4, p1, face_uv[f, 2], face_uv[f, 3], face_uv[f, 0], null, color, mat)
				}
			}
		}
	}
}*/