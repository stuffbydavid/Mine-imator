/// action_background_volumetric_fog_rays(show)
/// @arg show

function action_background_volumetric_fog_rays(show)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_volumetric_fog_rays, true)
			tl_value_set(e_value.BG_VOLUMETRIC_FOG_RAYS, show, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_volumetric_fog_rays, background_volumetric_fog_rays, show, false)
	}
	
	background_volumetric_fog_rays = show
}
