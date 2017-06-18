/// block_render_models_generate(models)
/// @arg models
/// @desc Generate triangles from the render models.

var models = argument0;

for (var m = 0; m < array_length_1d(models); m++)
{
	with (models[m])
	{
		var off = point3D_add(mc_builder.block_pos, offset);
		
		// Create elements
		for (var e = 0; e < element_amount; e++)
		{
			with (element[e])
			{
				var x1, x2, y1, y2, z1, z2;
				var p1, p2, p3, p4;
				var mat;
	
				x1 = from[X]; y1 = from[Y]; z1 = from[Z]
				x2 = to[X];	  y2 = to[Y];   z2 = to[Z]
		
				mat = matrix_multiply(matrix, matrix_create(off, vec3(0), vec3(1)))

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
					vbuffer_add_triangle(p1, p2, p3, face_uv[f, 0], face_uv[f, 1], face_uv[f, 2], mat, color)
					vbuffer_add_triangle(p3, p4, p1, face_uv[f, 2], face_uv[f, 3], face_uv[f, 0], mat, color)
				}
			}
		}
	}
}