/// view_shape_particles(timeline)
/// @arg timeline

function view_shape_particles(tl)
{
	var temp = tl.temp;
	
	view_shape_box(point3D_add(tl.world_pos, vec3(-3)), point3D_add(tl.world_pos, vec3(3)))
	
	if (temp = temp_edit && template_editor.show)
	{
		if (temp.pc_spawn_region_use)
		{
			if (temp.pc_bounding_box_type = "spawn")
				draw_set_color(c_red)
			
			switch (temp.pc_spawn_region_type)
			{
				case "sphere":
					view_shape_circle(tl.world_pos, temp.pc_spawn_region_sphere_radius)
					break
				
				case "cube":
					view_shape_box(point3D_add(tl.world_pos, vec3(-temp.pc_spawn_region_cube_size / 2)), 
								   point3D_add(tl.world_pos, vec3(temp.pc_spawn_region_cube_size / 2)))
					break
				
				case "box":
					view_shape_box(point3D(tl.world_pos[X] - temp.pc_spawn_region_box_size[X] / 2, 
										   tl.world_pos[Y] - temp.pc_spawn_region_box_size[Y] / 2, 
										   tl.world_pos[Z] - temp.pc_spawn_region_box_size[Z] / 2), 
								   point3D(tl.world_pos[X] + temp.pc_spawn_region_box_size[X] / 2, 
										   tl.world_pos[Y] + temp.pc_spawn_region_box_size[Y] / 2, 
										   tl.world_pos[Z] + temp.pc_spawn_region_box_size[Z] / 2))
					break
			}
		}
		
		if (temp.pc_bounding_box_type = "custom")
		{
			draw_set_color(c_red)
			view_shape_box(point3D(tl.world_pos[X] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_start[X], 
								   tl.world_pos[Y] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_start[Y], 
								   tl.world_pos[Z] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_start[Z]), 
						   point3D(tl.world_pos[X] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_end[X], 
								   tl.world_pos[Y] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_end[Y], 
								   tl.world_pos[Z] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_end[Z]))
		}
		
		draw_set_color(c_white)
	}
}
