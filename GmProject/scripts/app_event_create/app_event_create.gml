/// app_event_create()
/// @desc Entry point of the application.

function app_event_create()
{
	globalvar debug_indent, debug_timer;
	debug_indent = 0
	debug_info = dev_mode ? 1 : 0
	debug_info_corner = 2
	
	enums()
	randomize()
	gml_release_mode(true)
	objects_indexed()

	
	if (!app_startup())
		game_end()
}
