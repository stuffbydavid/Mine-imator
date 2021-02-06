/// toast_event_create()

toast_y = app.window_height + 8
toast_goal_y = toast_y
toast_width = 0
toast_height = 0
remove = false

text = ""
icon = ""
variant = e_toast.INFO
actions = ds_list_create()
remove_alpha = 1

time_created = current_time
dismiss_time = no_limit
iid = null
