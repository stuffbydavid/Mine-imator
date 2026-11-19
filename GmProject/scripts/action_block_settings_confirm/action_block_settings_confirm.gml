/// @desc Apply block settings and resume loading or regenerate the resource.

function action_block_settings_confirm()
{
	var popup, res, tlchanged;
	popup = popup_block_settings
	res = popup.resource

	// Finish scenery creation after the popup or resource loader closes
	if (popup.create_tl != null && popup_ani_type = "hide" && popup_ani = 0)
	{
		var tl, startplacing;
		tl = popup.create_tl
		startplacing = popup.create_place
		popup.create_tl = null
		popup.create_hobj = null
		popup.create_place = false
		popup.close_script = null
		
		popup_loading.close_script = null

		place_tl_render = true
		
		if (instance_exists(tl))
		{
			if (startplacing)
				app_start_place(false, tl, true)
			else
			{
				with (tl)
					tl_mark_placed(false)

				view_changed()
			}

			tl_update_list()
		}

		return 0
	}
	
	tlchanged = (
		res.scenery_tl_all_types != popup.tl_all_types ||
		!array_equals(res.scenery_tl_types, popup.tl_types)
	)
	
	if (popup.during_load && !res.ready)
	{
		res.scenery_tl_all_types = popup.tl_all_types
		res.scenery_tl_types = array_copy_1d(popup.tl_types)

		if (tlchanged)
		{
			mc_builder.block_tl_add = (res.scenery_tl_all_types || array_length(res.scenery_tl_types) > 0)
			
			with (res)
				mc_builder.block_tl_types = res_get_block_timeline_types()
		}

		popup_switch(popup_loading)
		return 0
	}

	if (popup.create_tl != null)
	{
		if (tlchanged)
		{
			// Keep popup choices in the original workbench history action
			var save = popup.create_hobj.scenery_res_save_obj;
			res.scenery_tl_all_types = popup.tl_all_types
			res.scenery_tl_types = array_copy_1d(popup.tl_types)
			save.scenery_tl_all_types = res.scenery_tl_all_types
			save.scenery_tl_types = array_copy_1d(res.scenery_tl_types)
			
			popup_loading.close_script = action_block_settings_confirm

			with (res)
			{
				load_folder = app.project_folder
				save_folder = app.project_folder
				res_load(true)
			}

			res_update_reload()
		}
	}
	else
	{
		var integritychanged, palettechanged, randomizechanged, filterenabled, filterchanged;
		integritychanged = (res.scenery_integrity != popup.scenery_integrity)
		palettechanged = (res.scenery_palette != popup.scenery_palette)
		randomizechanged = (res.scenery_randomize != popup.scenery_randomize)
		
		filterenabled = popup.filter_enabled
		if (filterenabled && popup.filter_mode = e_block_filter.REMOVE && array_length(popup.filter_array) = 0)
			filterenabled = false
		filterchanged = (
			res.scenery_filter_enabled != filterenabled ||
			res.scenery_filter_mode != popup.filter_mode ||
			!array_equals(res.scenery_filter_array, popup.filter_array)
		)

		if (tlchanged || integritychanged || palettechanged || randomizechanged || filterchanged)
			action_res_block_settings(popup.tl_all_types, popup.tl_types, popup.scenery_integrity, popup.scenery_palette, popup.scenery_randomize, filterenabled, popup.filter_mode, popup.filter_array)
	}

	if (popup_current = popup)
	{
		window_busy = ""
		window_focus = ""

		popup_ani_type = "hide"

		app_mouse_clear()
	}
}
