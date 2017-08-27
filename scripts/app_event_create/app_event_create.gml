/// app_event_create()
/// @desc Entry point of the application.

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