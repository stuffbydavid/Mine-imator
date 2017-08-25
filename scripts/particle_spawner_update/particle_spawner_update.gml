/// particle_spawner_update()
/// @desc Runs once per step and updates the particle spawning and their positions, scale, alpha, color etc.

if (app.exportmovie || !app.popup || !app.popup.block)
{
	// Iterate through missed steps
	for (var s = spawn_laststep; s < current_step; s++)
	{
		var temp;
		if (is_timeline)
			temp = id.temp
		else
			temp = select
		
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
							other.spawn_queue[i, other.spawn_queue_amount[i]] = id
							other.spawn_queue_amount[i]++
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
					repeat (floor(spawn_rate * temp.pc_spawn_amount))
						with (other)
							particle_spawner_spawn(other.id)
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
			
			// Delete after an amount of time
			pt.time++
			if (temp.pc_destroy_at_time && pt.time >= pt.timetolive)
			{
				with (pt)
					instance_destroy()
				continue
			}
			
			// Calculate animation frame
			if (!pt.type.temp)
			{
				var ani = particle_get_animation_percent(pt.spawntime, pt.type.sprite_frame_start, pt.type.sprite_frame_end, pt.anispeed, pt.type.sprite_animation_onend);
				if (ani = 1 && temp.pc_destroy_at_animation_finish && pt.type.sprite_animation_onend = 0) // Animation end
				{
					with (pt) instance_destroy()
					continue
				}
				pt.frame = round(pt.type.sprite_frame_start + (pt.type.sprite_frame_end - pt.type.sprite_frame_start) * ani)
			}
			
			
			if (is_timeline)
			{
				// Don't bother updating if hidden
				if (hide)
					continue
					
				// Don't bother updating if particles are disabled (and not exporting)
				if (!app.view_main.particles && (!app.view_second.particles || !app.view_second.show) && !app.exportmovie)
					continue
			}
			
			// Speed TODO rewrite with vec2
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
				if (is_timeline)
				{
					if (value[e_value.ATTRACTOR] != app)
					{
						if (pt.type.orbit)
							pt.spd[a] += clamp(value[e_value.ATTRACTOR].pos[a] - pt.pos[a], -value[e_value.FORCE], value[e_value.FORCE]) / 60
						else
							pt.spd[a] += clamp(value[e_value.ATTRACTOR].pos[a] - pos[a], -value[e_value.FORCE], value[e_value.FORCE]) / 60
					}
				}
			}
			
			// Scale
			pt.scale += pt.scale_add
			if (pt.scale <= 0)
			{
				with (pt) instance_destroy()
				continue
			}
			
			// Alpha
			pt.alpha += pt.alpha_add
			if (pt.alpha <= 0)
			{
				with (pt) instance_destroy()
				continue
			}
			
			// Color mix
			if (pt.color_mix > -1)
				pt.color = merge_color(pt.color_mix_start, pt.color_mix, clamp((s - pt.spawntime) / pt.color_mix_time, 0, 1))
			
			// Bounding box
			if (temp.pc_bounding_box_type > 0 && pt.type.bounding_box)
			{
				// Ground
				if (temp.pc_bounding_box_type = 1) 
				{
					if (pt.pos[Z] < temp.pc_bounding_box_ground_z)
					{
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
						}
						
						// Keep above ground
						pt.pos[Z] = max(pt.pos[Z], temp.pc_bounding_box_ground_z)
					}
				}
				else
				{
					var boxstart, boxend;
					
					// Spawn region
					if (temp.pc_bounding_box_type = 2)
					{
						if (!temp.pc_spawn_region_use)
							continue
							
						if (temp.pc_spawn_region_type = "sphere")
						{
							var dis = point3D_distance(pt.pos, pos);
							if (dis > temp.pc_spawn_region_sphere_radius)
							{
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
								pt.pos = point3D_add(pos, vec3_mul(vec3_normalize(point3D_sub(pt.pos, pos)), temp.pc_spawn_region_sphere_radius))
							}
							continue
						}
						else if (temp.pc_spawn_region_type = "cube")
						{
							for (var a = X; a <= Z; a++)
							{
								boxstart[a] = pos[a] - temp.pc_spawn_region_cube_size / 2
								boxend[a] = pos[a] + temp.pc_spawn_region_cube_size / 2
							}
						}
						else if (temp.pc_spawn_region_type = "box")
						{
							for (var a = X; a <= Z; a++)
							{
								boxstart[a] = pos[a] - temp.pc_spawn_region_box_size[a] / 2
								boxend[a] = pos[a] + temp.pc_spawn_region_box_size[a] / 2
							}
						}
					}
					
					// Box
					else if (temp.pc_bounding_box_type = 3) 
					{
						for (var a = X; a <= Z; a++)
						{
							boxstart[a] = pos[a] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_start[a]
							boxend[a] = pos[a] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_end[a]
						}
					}
					
					for (var a = X; a <= Z; a++) 
					{
						if (pt.pos[a] < boxstart[a] || pt.pos[a] > boxend[a])
						{
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
	}
}

spawn_laststep = current_step
