/// recent_add()
/// @desc Adds the opened project to the top of the recent list.

function recent_add()
{
	recent_add_wait = false
	
	// Find project in list
	var obj = null;
	for (var i = 0; i < ds_list_size(recent_list); i++)
	{
		with (recent_list[|i])
		{
			if (filename != app.project_file)
				break
			
			obj = id
			ds_list_delete_value(app.recent_list, id)
			if (thumbnail != null)
				texture_free(thumbnail)
		}
		
		if (obj != null)
			break
	}
	
	// Create thumbnail
	var thumbnailfn, surf;
	thumbnailfn = project_folder + "/thumbnail.png"
	surf = null
	render_start(surf, null, recent_thumbnail_width, recent_thumbnail_height)
	render_low()
	surf = render_done()
	surface_save_lib(surf, thumbnailfn)
	surface_free(surf)
	
	// Project not added, create new object
	if (obj = null)
		obj = new_obj(obj_recent)
	
	// Store data
	with (obj)
	{
		name = app.project_name
		author = app.project_author
		description = app.project_description
		thumbnail = texture_create(thumbnailfn)
		
		filename = app.project_file
		last_opened = date_current_datetime()
		pinned = false
		ds_list_insert(app.recent_list, 0, id)
	}
	
	recent_update()
	recent_save()
}
