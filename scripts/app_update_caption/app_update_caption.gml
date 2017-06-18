/// app_update_caption()

if (project_name != "")
    window_set_caption(project_name + string_repeat(" * ", project_changed) + " - Mine-imator")
else
    window_set_caption("Mine-imator")
