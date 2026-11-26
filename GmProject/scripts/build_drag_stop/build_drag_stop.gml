/// @desc Finishes or cancels a build block drag.

function build_drag_stop(cancel = false)
{
	if (build_drag_block = null)
		return 0

	if (build_drag_active)
	{
		if (cancel)
		{
			if (build_drag_source != null && !build_drag_copy && instance_exists(build_drag_source))
			{
				build_drag_source.blocks[build_drag_source_slot] = [
					build_drag_block[0], build_drag_block[1], array_copy_1d(build_drag_block[2])
				]
				action_build_hotbar_select(build_hotbar_slot)
			}
		}
		else
			action_build_hotbar_drop()

		if (window_busy = "build/drag")
			window_busy = place_busy

		mouse_cursor = cr_default
		window_set_cursor(cr_default)
		app_mouse_clear()
	}

	build_drag_block = null
	build_drag_res = null
	build_drag_source = null
	build_drag_source_slot = -1
	build_drag_target = null
	build_drag_target_slot = -1
	build_drag_insert = false
	build_drag_active = false
	build_drag_copy = false
}
