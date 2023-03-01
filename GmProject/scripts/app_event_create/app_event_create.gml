/// app_event_create()
/// @desc Entry point of the application.

function app_event_create()
{
	globalvar debug_indent, debug_timer;
	debug_indent = 0
	debug_info = dev_mode
	
	enums()
	randomize()
	gml_release_mode(true)
	
	if (!app_startup())
		game_end()
}
