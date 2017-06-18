/// app_event_create()
/// @desc Entry point of the application.

if (!app_startup())
{
    game_end()
    return 0
}

project_reset()

if (dev_mode)
{
    popup_newproject_clear()
    project_create()
}
else
    popup_show(popup_startup)
