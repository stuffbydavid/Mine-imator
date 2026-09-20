/// app_start_place(tl, spawn)

function app_start_place(tl, spawn)
{
	window_busy = "place"
	
	place_spawn = spawn
	
	place_view_pos = null
	place_view_air = false
	place_view_color = 0
	place_view_normal = vec3(0)
	
	place_tl = tl
	place_tl_render = false
	place_tl_parent = tl.parent
	place_tl_parent_index = ds_list_find_index(tl.parent.tree_list, tl)
	place_sca = vec3(tl.value_default[e_value.SCA_X], tl.value_default[e_value.SCA_Y], tl.value_default[e_value.SCA_Z])
	
	place_target_tl = null
	place_target_tl_part_of = null
	
	view_main.update_place_surfaces = true
	view_main.place_depth_value = 0.995
	view_second.update_place_surfaces = true
	view_second.place_depth_value = 0.995
	
	with (place_tl)
		tl_mark_placed(true)
}
