/// app_event_create()
/// @desc Entry point of the application.

function app_event_create()
{
	enums()
	gml_release_mode(true)
	random_set_seed(0)
	
	// Developent settings and arguments
	debug_startup()
	
	// Ensure deterministic behavior for benchmarks
	if (benchmark_project != "")
		random_set_seed(0)
	else
		randomize()
	
	// Start program
	if (!app_startup())
		game_end()
}
