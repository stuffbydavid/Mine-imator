/// @desc Called when an object has changed its transform, visibility or transparency
/// in the project and views and render lists need updating.

function render_world_changed()
{
	render_world_id++
	
	app.render_list_update = true
	
	with (obj_timeline)
		if (type = e_tl_type.CAMERA)
			render_list_update = true
		
	with (obj_view)
		render_list_update = true
	
	view_changed()
}
