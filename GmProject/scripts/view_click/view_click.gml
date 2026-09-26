/// view_click(view, camera, [ctrl])
/// @arg view
/// @arg camera
/// @arg [ctrl]

function view_click(view, cam, ctrl = false)
{
	var surf = surface_create(content_width, content_height);
	
	render_camera = cam
	render_ratio = content_width / content_height
	
	surface_set_target(surf)
	{
		draw_clear(c_black)
		render_world_start()
		render_world(e_render_mode.CLICK)
		render_world_done()
	}
	surface_reset_target()
	
	var tl = surface_getpixel(surf, mouse_x - content_x, mouse_y - content_y);
	
	if (tl > 0)
	{
		// Prefer a model root until it or one of its parts is selected
		if (!ctrl && !keyboard_check(vk_control))
		{
			if (tl.type = e_tl_type.MODEL_PART && tl.part_of != null)
			{
				var root, partselected;
				root = tl.part_of
				partselected = root.selected

				if (!partselected)
				{
					for (var p = 0; p < ds_list_size(root.part_list); p++)
					{
						if (root.part_list[|p].selected)
						{
							partselected = true
							break
						}
					}
				}

				if (!partselected)
					tl = root
			}
			else if (tl.type = e_tl_type.BLOCK && !tl.animated)
			{
				// Prefer the structure until one of its blocks is selected
				var structure, blockselected;
				structure = tl.parent
				while (structure != null && structure != app && !type_is_structure(structure.type))
					structure = structure.parent

				if (structure != null && structure != app)
				{
					blockselected = structure.selected
					if (!blockselected)
					{
						for (var s = 0; s < ds_list_size(structure.tree_list); s++)
						{
							var sibling = structure.tree_list[|s];
							if (sibling.type = e_tl_type.BLOCK && sibling.selected)
							{
								blockselected = true
								break
							}
						}
					}

					if (!blockselected)
						tl = structure
				}
			}
			else if (!tl_edit)
			{
				while (tl.parent != app && !tl.parent.lock && tl_update_list_filter(tl.parent))
					tl = tl.parent
			}
		}
		
		// Select
		action_tl_select(tl)
		
		// Jump in list
		if (setting_timeline_select_jump)
			tl_jump(tl)
	}
	else
		if (!keyboard_check(vk_shift))
			action_tl_deselect_all()
	
	surface_free(surf)
}
