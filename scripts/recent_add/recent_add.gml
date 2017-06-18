/// recent_add()
/// @desc Adds the opened project to the top of the recent list.

var n, surf, thumbnailfn;

recent_add_wait = false

// Find index
for (n = 0; n < recent_amount; n++)
    if (recent_filename[n] = project_file)
        break
        
// Remove old
if (n < recent_amount)
    recent_remove(n)

recent_amount++

// Push up
for (var r = recent_amount; r > 0; r--)
{
    recent_filename[r] = recent_filename[r - 1]
    recent_name[r] = recent_name[r - 1]
    recent_author[r] = recent_author[r - 1]
    recent_description[r] = recent_description[r - 1]
    recent_date[r] = recent_date[r - 1]
    recent_thumbnail[r] = recent_thumbnail[r - 1]
}

// Create thumbnail
thumbnailfn = project_folder + "\\thumbnail.png"
surf = null
render_start(surf, timeline_camera, recent_thumbnail_width, recent_thumbnail_height)
render_low()
surf = render_done()
surface_export(surf, thumbnailfn)
surface_free(surf)

// Store
recent_filename[0] = project_file
recent_name[0] = project_name
recent_author[0] = project_author
recent_description[0] = project_description
recent_date[0] = date_current_datetime()
recent_thumbnail[0] = texture_create(thumbnailfn)
