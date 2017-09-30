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

// Shortcut to a new project
if (dev_mode)
{
	popup_newproject_clear()
	project_create()
}
else
{
	project_reset()
	popup_show(popup_startup)
}