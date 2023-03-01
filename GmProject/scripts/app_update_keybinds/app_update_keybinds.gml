/// app_update_keybinds()

function app_update_keybinds()
{
	var obj, check, navclear;
	navclear = false
	
	for (var i = 0; i < e_keybind.amount; i++)
	{
		obj = keybinds[i]
		
		check = keybind_check(obj, "keyboard_check")
		
		obj.released = false
		
		if (obj.active)
			obj.released = keybind_check(obj, "keyboard_check_released")
		
		obj.pressed = keybind_check(obj, "keyboard_check_pressed")
		obj.active = check
		
		if (obj.pressed && obj.navigation && string_contains(window_busy, "camera"))
			navclear = true
	}
	
	if (navclear)
	{
		for (var i = 0; i < e_keybind.amount; i++)
		{
			obj = keybinds[i]
		
			if (!obj.navigation)
			{
				obj.pressed = false
				obj.active = false
			}
		}
	}
}
