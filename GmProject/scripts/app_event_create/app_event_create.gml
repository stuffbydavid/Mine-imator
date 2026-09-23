/// app_event_create()
/// @desc Entry point of the application.

function app_event_create()
{
	globalvar debug_indent, debug_timer;
	debug_indent = 0
	debug_info = dev_mode ? 1 : 0
	debug_info_corner = 2
	
	enums()
	gml_release_mode(true)
	objects_indexed()
	
	// Developent settings and arguments
	debug_startup()
	
	// Ensure deterministic behavior for tests
	if (test_project != "")
		random_set_seed(0)
	else
		randomize()
	
	// Start program
	if (!app_startup())
		game_end()
}
