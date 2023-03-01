/// tl_update_marker_length()
/// @arg Updates length of markers in the animation.

function tl_update_marker_length()
{
	app.timeline_marker_length = 0
	
	with (obj_marker)
		app.timeline_marker_length = max(pos, app.timeline_marker_length);
}