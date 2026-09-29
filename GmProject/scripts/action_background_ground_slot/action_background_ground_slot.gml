function action_background_ground_slot(index)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_ground_slot, true)
			tl_value_set(e_value.BG_GROUND_SLOT, index, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_ground_slot, background_ground_slot, index, true)
	}
	
	background_ground_slot = index
	
	background_ground_update_texture()
	background_ground_update_texture_normal()
	background_ground_update_texture_material()
}
