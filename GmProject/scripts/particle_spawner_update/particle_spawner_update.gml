/// particle_spawner_update(spawner)
/// @desc Runs once per step and updates the particle spawning and their positions, scale, alpha, color etc.

function particle_spawner_update(spawner)
{
	if (app.window_state = "export_movie" || !app.popup || !app.popup.block)
	{
		var temp;
		if (is_timeline)
		{
			temp = id.temp
			spawn_currentstep = floor(app.background_time)
			
			if (floor(app.timeline_marker_previous) > floor(app.timeline_marker))
				particle_spawner_clear()
		}
		else
		{
			temp = select
			spawn_currentstep = current_step
		}
		
		// Iterate through missed steps
		for (var s = spawn_laststep; s < spawn_currentstep; s++)
		{
			if (temp.pc_spawn_constant)
			{
				var spawn;
				if (is_timeline)
					spawn = value[e_value.SPAWN]
				else
					spawn = spawn_active
				
				if (spawn)
				{
					// Fill spawn array
					if (spawn_queue_start < 0 || s >= spawn_queue_start + minute_steps)
					{
						for (var t = 0; t < minute_steps; t++)
							spawn_queue_amount[t] = 0
						
						with (obj_particle_type)
						{
							if (creator != temp)
								continue
							
							repeat (floor(spawn_rate * temp.pc_spawn_amount))
							{
								var i = irandom(minute_steps - 1);
								spawner.spawn_queue[i, spawner.spawn_queue_amount[i]] = real(id)
								spawner.spawn_queue_amount[i]++
							}
						}
						spawn_queue_start = s
					}
					
					// Check current queue slot
					var slot = s - spawn_queue_start;
					for (var t = 0; t < spawn_queue_amount[slot]; t++)
						particle_spawner_spawn(spawn_queue[slot, t])
				}
			}
			else 
			{
				if (fire) 
				{
					with (obj_particle_type) 
					{
						if (creator != temp)
							continue
						
						// Repeat through amount of particles to fire
						repeat (floor(spawn_rate * temp.pc_spawn_amount))
						{
							other.single_fire_count++
							with (other)
								particle_spawner_spawn(other.id)
						}
						
						other.single_fire_count = 0
					}
					fire = false
				}
			}
			
			// Update particles
			for (var i = 0; i < ds_list_size(particle_list); i++)
			{
				var pt = particle_list[|i];
				
				// Delete at amount
				if (temp.pc_destroy_at_amount && ds_list_size(particle_list) > temp.pc_destroy_at_amount_val)
				{
					with (pt)
						instance_destroy()
					continue
				}
				
				// Freeze particles
				if (is_timeline && pt.creator.value[e_value.FREEZE])
					pt.freezetime++
				
				if (!is_timeline || !pt.creator.value[e_value.FREEZE])
				{
					// Delete after an amount of time
					pt.time++
					if (temp.pc_destroy_at_time && pt.time >= pt.time_to_live)
					{
						with (pt)
							instance_destroy()
						continue
					}
					
					// Calculate animation frame
					if (pt.type.temp = particle_sheet)
					{
						var ani = particle_get_animation_percent(spawn_currentstep, (pt.spawntime + pt.freezetime), pt.type.sprite_frame_start, pt.type.sprite_frame_end, pt.anispeed, pt.type.sprite_animation_onend);
						if (ani = 1 && temp.pc_destroy_at_animation_finish && pt.type.sprite_animation_onend = 0) // Animation end
						{
							with (pt) instance_destroy()
							continue
						}
						pt.frame = round(pt.type.sprite_frame_start + (pt.type.sprite_frame_end - pt.type.sprite_frame_start) * ani)
					}
					else if (pt.type.temp = particle_template)
					{
						// Update particle frame if frame isn't animation is static
						if (!pt.type.sprite_template_still_frame)
						{
							var template = particle_template_map[?pt.type.sprite_template];
							
							var startf, endf;
							startf = (pt.type.sprite_template_reverse ? (template.frames - 1) : 0)
							endf = (pt.type.sprite_template_reverse ? 0 : (template.frames - 1))
							
							var ani = particle_get_animation_percent(spawn_currentstep, (pt.spawntime + pt.freezetime), startf, endf, pt.anispeed, pt.type.sprite_animation_onend);
							if (ani = 1 && temp.pc_destroy_at_animation_finish && pt.type.sprite_animation_onend = 0) // Animation end
							{
								with (pt) instance_destroy()
								continue
							}
							pt.frame = round(startf + (endf - startf) * ani)
						}
					}
					
					if (is_timeline)
					{
						// Don't bother updating if hidden
						if (hide)
							continue
						
						// Don't bother updating if particles are disabled (and not exporting)
						if (!app.view_main.particles && (!app.view_second.particles || !app.view_second.show) && app.window_state != "export_movie" && app.window_state != "export_image")
							continue
					}
					
					// Angle
					for (var a = X; a <= Z; a++)
						pt.pos[a] += pt.angle[a] * pt.angle_speed
					
					pt.angle_speed += pt.angle_speed_add
					pt.angle_speed *= pt.angle_speed_mul
					
					// Speed
					for (var a = X; a <= Z; a++)
					{
						pt.pos[a] += pt.spd[a]
						pt.spd[a] += pt.spd_add[a]
						pt.spd[a] *= pt.spd_mul[a]
						if (pt.type.temp)
						{
							pt.rot[a] += pt.rot_spd[a]
							pt.rot_spd[a] += pt.rot_spd_add[a]
							pt.rot_spd[a] *= pt.rot_spd_mul[a]
						}
						
						// Attractor
						if (is_timeline && value[e_value.ATTRACTOR] != null)
						{
							var att = value[e_value.ATTRACTOR];
							if (att.type != e_tl_type.PATH)
							{
								if (pt.type.orbit)
									pt.spd[a] += (clamp(att.world_pos[a] - pt.pos[a], -value[e_value.FORCE], value[e_value.FORCE]) / 60)
								else
									pt.spd[a] += (clamp(att.world_pos[a] - world_pos[a], -value[e_value.FORCE], value[e_value.FORCE]) / 60)
							}
						}
					}
					
					if (is_timeline && value[e_value.ATTRACTOR] != null && value[e_value.ATTRACTOR].type = e_tl_type.PATH)
					{
						// Get nearest point in path table
						var att, pointpos, pointposnext, pointdis, curdis, curpos, pointi, points, v, d, p;
						att = value[e_value.ATTRACTOR]
						pointpos = [0, 0, 0]
						pointdis = no_limit
						pointi = 0
						points = array_length(att.path_table_matrix)
						
						for (var j = 0; j < points; j += 3)
						{
							curpos = att.path_table_matrix[j]
							curdis = point3D_distance(pt.pos, curpos) // possibly hundreds of distance checks in each particle.. yikes
							
							// New nearest point?
							if (curdis < pointdis)
							{
								pointi = j
								pointdis = curdis
								pointpos = curpos
							}
						}
						
						var t, n, b;
						
						// Direction to next point
						t = [pointpos[PATH_TANGENT_X], pointpos[PATH_TANGENT_Y], pointpos[PATH_TANGENT_Z]]
						
						// Get nearest position between two points given the current particle position
						v = vec3_sub(pt.pos, pointpos)
						d = vec3_dot(v, t)
						p = vec3_add(pointpos, vec3_mul(t, d))
						n = vec3_normalize(vec3_sub(p, pt.pos))
						
						// Direction around path direction
						b = vec3_cross(t, n)
						
						// Add forces
						for (var a = X; a <= Z; a++)
						{
							pt.pos[a] += (clamp(p[a] - pt.pos[a], -value[e_value.FORCE], value[e_value.FORCE]) / 60)
							pt.pos[a] += (t[a] * value[e_value.FORCE_DIRECTIONAL])
							pt.pos[a] += (b[a] * value[e_value.FORCE_VORTEX])
						}
					}
					
					// Angle (Sprites)
					pt.sprite_angle += pt.sprite_angle_add
					
					// Scale
					pt.scale += pt.scale_add
					if (pt.scale <= 0)
					{
						with (pt)
							instance_destroy()
						continue
					}
					
					// Alpha
					pt.alpha += pt.alpha_add
					if (pt.alpha <= 0)
					{
						with (pt)
							instance_destroy()
						continue
					}
					
					// Color mix
					if (pt.color_mix > -1)
						pt.color = merge_color(pt.color_mix_start, pt.color_mix, clamp((s - pt.spawntime) / pt.color_mix_time, 0, 1))
					
					// Bounding box
					var hit_bounding_box = false;
					
					if (temp.pc_bounding_box_type != "none" && pt.type.bounding_box)
					{
						// Ground
						if (temp.pc_bounding_box_type = "ground") 
						{
							if (pt.pos[Z] < temp.pc_bounding_box_ground_z)
							{
								hit_bounding_box = true
								
								if (pt.type.bounce)
								{
									// Flip Z speed
									pt.spd[Z] *= -pt.type.bounce_factor
									
									if (abs(pt.spd[Z]) < 0.25)
										pt.spd[Z] = 0
									
									// Flip rotation
									for (var b = X; b <= Z; b++)
										pt.rot_spd[b] *= -0.5
									
									pt.spd_mul[X] *= 0.995
									pt.spd_mul[X] *= 0.995
									
									// Reflect angle
									pt.angle = vec3_reflect(pt.angle, vec3(0, 0, 1))
									pt.angle_speed *= pt.type.bounce_factor
								}
								
								// Keep above ground
								pt.pos[Z] = max(pt.pos[Z], temp.pc_bounding_box_ground_z)
							}
						}
						else
						{
							var boxstart, boxend;
							boxstart = null
							boxend = null
							
							// Spawn region
							if (temp.pc_bounding_box_type = "spawn")
							{
								if (!temp.pc_spawn_region_use)
									continue
								
								if (temp.pc_spawn_region_type = "sphere")
								{
									var dis = point3D_distance(pt.pos, world_pos);
									if (dis > temp.pc_spawn_region_sphere_radius)
									{
										hit_bounding_box = true
										
										for (var a = X; a <= Z; a++)
										{
											if (pt.type.bounce)
											{
												// Invert speed
												pt.spd[a] *= -pt.type.bounce_factor
												
												if (abs(pt.spd[a]) < 0.1)
													pt.spd[a] = 0
												
												// Flip and slow down rotation
												pt.rot_spd[a] *= -0.5
											}
										}
										
										// Reflect angle
										pt.angle = vec3_reflect(pt.angle, vec3_normalize(vec3_sub(pt.pos, world_pos)))
										pt.angle_speed *= pt.type.bounce_factor
										
										pt.pos = point3D_add(world_pos, vec3_mul(vec3_normalize(point3D_sub(pt.pos, world_pos)), temp.pc_spawn_region_sphere_radius))
									}
								}
								else if (temp.pc_spawn_region_type = "cube")
								{
									for (var a = X; a <= Z; a++)
									{
										boxstart[a] = world_pos[a] - temp.pc_spawn_region_cube_size / 2
										boxend[a] = world_pos[a] + temp.pc_spawn_region_cube_size / 2
									}
								}
								else if (temp.pc_spawn_region_type = "box")
								{
									for (var a = X; a <= Z; a++)
									{
										boxstart[a] = world_pos[a] - temp.pc_spawn_region_box_size[a] / 2
										boxend[a] = world_pos[a] + temp.pc_spawn_region_box_size[a] / 2
									}
								}
								else if (temp.pc_spawn_region_type = "path" && temp.pc_spawn_region_path != null)
								{
									// Get nearest point in path table
									var path, pointpos, pointposnext, pointdis, curdis, curpos, pointi, points, v, d, p, t, dis, dir;
									path = temp.pc_spawn_region_path
									pointpos = [0, 0, 0]
									pointdis = no_limit
									pointi = 0
									points = array_length(path.path_table_matrix)
									
									for (var j = 0; j < points; j += 3)
									{
										curpos = path.path_table_matrix[j]
										curdis = point3D_distance(pt.pos, curpos) // possibly hundreds of distance checks in each particle.. yikes
										
										// New nearest point?
										if (curdis < pointdis)
										{
											pointi = j
											pointdis = curdis
											pointpos = curpos
										}
									}
									
									// Direction to next point
									t = [pointpos[PATH_TANGENT_X], pointpos[PATH_TANGENT_Y], pointpos[PATH_TANGENT_Z]];
									
									// Get nearest position between two points given the current particle position
									v = vec3_sub(pt.pos, pointpos)
									d = vec3_dot(v, t)
									p = vec3_add(pointpos, vec3_mul(t, d))
									
									dis = point3D_distance(pt.pos, p)
									
									if (dis > temp.pc_spawn_region_path_radius)
									{
										dir = vec3_normalize(vec3_sub(pt.pos, p))
										pt.pos = vec3_add(p, vec3_mul(dir, temp.pc_spawn_region_path_radius))
										
										// Reflect angle
										pt.angle = vec3_reflect(pt.angle, vec3_normalize(vec3_sub(pt.pos, p)))
										pt.angle_speed *= pt.type.bounce_factor
									}	
								}
							}
							
							// Box
							else if (temp.pc_bounding_box_type = "custom") 
							{
								for (var a = X; a <= Z; a++)
								{
									boxstart[a] = world_pos[a] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_start[a]
									boxend[a] = world_pos[a] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_end[a]
								}
							}
							
							// Calculate box bounding box
							if (boxstart != null)
							{
								var normal = null;
								
								// Reflect off faces
								if (pt.pos[X] < boxstart[X])
									normal = vec3(1, 0, 0)
								
								if (pt.pos[X] > boxend[X])
									normal = vec3(-1, 0, 0)	
								
								if (pt.pos[Y] < boxstart[Y])
									normal = vec3(0, 1, 0)
								
								if (pt.pos[Y] > boxend[Y])
									normal = vec3(0, -1, 0)	
								
								if (pt.pos[Z] < boxstart[Z])
									normal = vec3(0, 0, 1)
								
								if (pt.pos[Z] > boxend[Z])
									normal = vec3(0, 0, -1)	
								
								// Reflect angle
								if (normal != null)
								{
									hit_bounding_box = true
									
									for (var a = X; a <= Z; a++) 
										pt.pos[a] = clamp(pt.pos[a], boxstart[a], boxend[a]) 
									
									pt.angle = vec3_reflect(pt.angle, normal)
									pt.angle_speed *= pt.type.bounce_factor
								}
								
								for (var a = X; a <= Z; a++) 
								{
									if (pt.pos[a] < boxstart[a] || pt.pos[a] > boxend[a])
									{
										hit_bounding_box = true
										
										// Keep within box
										pt.pos[a] = clamp(pt.pos[a], boxstart[a], boxend[a]) 
										if (pt.type.bounce)
										{
											// Invert speed
											pt.spd[a] *= -pt.type.bounce_factor 
											
											if (abs(pt.spd[a]) < 0.25)
												pt.spd[a] = 0
											
											// Flip and slow down rotation
											for (var b = X; b <= Z; b++)
												pt.rot_spd[b] *= -0.5
										}
									}
								}
							}
						}
					}
					
					// Destroy particle
					if (hit_bounding_box && temp.pc_destroy_at_bounding_box) 
					{ 
						instance_destroy(pt) 
						continue 
					} 
				}
			}
		}
	}
	
	spawn_laststep = spawn_currentstep
}
