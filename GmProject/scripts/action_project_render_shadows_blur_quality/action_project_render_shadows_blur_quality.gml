/// action_project_render_shadows_blur_quality(value, add)
/// @arg value
/// @arg add

function action_project_render_shadows_blur_quality(val, add)
{
	action_project_render_preset_edit_locked()
	
	var blurquality = render_preset_edit.standard_shadows_blur_quality;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_blur_quality, blurquality, blurquality * add + val, true)
	
	render_preset_edit.standard_shadows_blur_quality = blurquality * add + val
}
