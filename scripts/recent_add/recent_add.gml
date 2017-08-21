/// recent_add()
/// @desc Adds the opened project to the top of the recent list.

recent_add_wait = false

// Remove old
var index;
for (index = 0; index < ds_list_size(recent_list); index++)
{
	if (recent_list[|index].filename = project_file)
	{
		with (recent_list[|index])
			instance_destroy()
		break
	}
}

// Create thumbnail
var thumbnailfn, surf;
thumbnailfn = project_folder + "\\thumbnail.png"
surf = null
render_start(surf, timeline_camera, recent_thumbnail_width, recent_thumbnail_height)
render_low()
surf = render_done()
surface_export(surf, thumbnailfn)
surface_free(surf)

// Store
with (new(obj_recent))
{
	filename = app.project_file
	name = app.project_name
	author = app.project_author
	description = app.project_description
	date = date_current_datetime()
	thumbnail = texture_create(thumbnailfn)
	ds_list_insert(app.recent_list, index, id)
}