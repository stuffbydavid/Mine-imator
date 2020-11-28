/// context_menu_draw()

if (context_menu_level_amount = 0)
	return 0

if (context_menu_name != "")
	window_busy = ""

context_menu_mouseon = false
context_menu_mouseon_item = null
axis_edit = context_menu_copy_axis_edit

// Reset which mouseon level status
if (context_menu_mouseon_reset)
{
	context_menu_mouseon_level = 0
	context_menu_mouseon_reset = false
}

// Draw context menus
for (var i = 0; i < context_menu_level_amount; i++)
	context_menu_draw_level(i)

// Update list items that trigger additional menus
with (obj_list_item)
{
	if (disabled || (context_menu_name = "" && context_menu_script = null) || (app.context_menu_mouseon_level > 0 && (app.context_menu_level[|1].name = context_menu_name)))
		continue
	
	if (id = other.context_menu_mouseon_item)
		hovertime += 60 / room_speed
	else
		hovertime -= 60 / room_speed
	
	hovertime = clamp(hovertime, 0, 3)
	
	if (!context_menu_active && hovertime = 3)
	{
		context_menu_active = true
		with (app)
			context_menu_add_level(other.context_menu_name, other.draw_x, other.draw_y, other)
	}
	
	if (context_menu_active && hovertime = 0)
	{
		context_menu_active = false
		app.context_menu_mouseon_level = 0
		
		with (obj_context_menu_level)
		{
			if (level > 0 && name = other.context_menu_name)
			{
				ds_list_delete_value(app.context_menu_level, id)
				app.context_menu_level_amount--
				
				list_destroy(level_list)
				instance_destroy()
			}
		}
	}
}

// Close menu
if (((mouse_left_pressed || mouse_right_pressed) && !context_menu_mouseon) || 
	(mouse_left_released && (!context_menu_mouseon || (context_menu_mouseon_item != null && !context_menu_mouseon_item.disabled && context_menu_mouseon_item.context_menu_name = ""))))
	context_menu_close()

if (window_busy = "" && context_menu_name != "")
	window_busy = "contextmenu"
