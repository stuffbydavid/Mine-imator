/// @desc Updates build block dragging and handles cancellation.

function build_drag_update()
{
	if (build_drag_block = null)
		return false

	build_drag_target = null
	build_drag_target_slot = -1
	build_drag_insert = false

	if (!window_has_focus() || keyboard_check_pressed(vk_escape) || mouse_right_pressed)
	{
		build_drag_stop(true)
		return true
	}

	if (!build_drag_active)
	{
		// Handle clicks before the drag threshold is reached
		if (!mouse_left)
		{
			var add = (build_drag_source = null && keyboard_check(vk_shift));
			if (add)
			{
				action_build_hotbar_add(build_drag_block)
				app_mouse_clear()
			}

			build_drag_stop(true)
			return add
		}

		if (mouse_move > 5)
		{
			build_drag_active = true
			build_drag_copy = keyboard_check(vk_control)
			
			window_busy = "build/drag"
			
			place_pos = null
			place_view_pos = null
			
			if (build_box_render != null)
			{
				build_box_render = null
				view_changed()
			}

			// Moving a hotbar block leaves its cell empty
			if (build_drag_source != null && !build_drag_copy)
			{
				build_drag_source.blocks[build_drag_source_slot] = [ false, "", [] ]
				if (build_drag_source = build_hotbar_current && build_drag_source_slot = build_hotbar_slot)
					build_tool.build_selected = null
			}
		}
	}

	return true
}
