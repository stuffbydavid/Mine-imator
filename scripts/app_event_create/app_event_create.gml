/// app_event_create()
/// @desc Entry point of the application.

globalvar debug_indent;
debug_indent = 0
debug_info = false

enums()
randomize()

if (!app_startup())
{
	game_end()
	return 0
}