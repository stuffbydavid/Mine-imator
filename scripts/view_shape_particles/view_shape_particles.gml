/// view_shape_particles()

view_shape_box(point3D_add(pos, vec3(-3)), point3D_add(pos, vec3(3)))

if (temp_edit = temp && app.template_editor.show)
{
	if (temp.pc_spawn_region_use)
	{
		if (temp.pc_bounding_box_type = 2)
			draw_set_color(c_red)
		
		switch (temp.pc_spawn_region_type)
		{
			case "sphere":
				view_shape_circle(pos, temp.pc_spawn_region_sphere_radius)
				break
				
			case "cube":
				view_shape_box(point3D_add(pos, vec3(-temp.pc_spawn_region_cube_size / 2)), 
								 point3D_add(pos, vec3(temp.pc_spawn_region_cube_size / 2)))
				break
			
			case "box":
				view_shape_box(point3D(pos[X] - temp.pc_spawn_region_box_size[X] / 2, 
									   pos[Y] - temp.pc_spawn_region_box_size[Y] / 2, 
									   pos[Z] - temp.pc_spawn_region_box_size[Z] / 2), 
							   point3D(pos[X] + temp.pc_spawn_region_box_size[X] / 2, 
									   pos[Y] + temp.pc_spawn_region_box_size[Y] / 2, 
									   pos[Z] + temp.pc_spawn_region_box_size[Z] / 2))
				break
		}
	}
	
	if (temp.pc_bounding_box_type = 3)
	{
		draw_set_color(c_red)
		view_shape_box(point3D(pos[X] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_start[X], 
							   pos[Y] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_start[Y], 
							   pos[Z] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_start[Z]), 
					   point3D(pos[X] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_end[X], 
							   pos[Y] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_end[Y], 
							   pos[Z] * temp.pc_bounding_box_relative + temp.pc_bounding_box_custom_end[Z]))
	}

	draw_set_color(c_white)
}
