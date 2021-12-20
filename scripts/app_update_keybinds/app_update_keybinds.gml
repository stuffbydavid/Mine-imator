/// app_update_keybinds()

function app_update_keybinds()
{
	if (window_busy != keybind_window_last)
	{
		keybind_active = null
		keybind_window_last = window_busy 
	}
	else
	{
		if (!(keyboard_check(vk_anykey) || keyboard_check_released(vk_anykey)))
		{
			if (keybind_active != null)
				keybind_active = null
		
			return 0
		}
	}
	
	var obj, check;
	
	for (var i = 0; i < e_keybind.amount; i++)
	{
		obj = keybinds[i]
		
		if (keybind_active = obj || keybind_active = null)
		{
			check = keybind_check(obj)
			obj.released = (obj.active && !check)
			obj.pressed = (!obj.active && check)
			obj.active = check
		}
		else
		{
			check = false
			obj.pressed = false
			obj.released = false
			obj.active = false
		}
		
		if (obj.pressed && !obj.navigation)
			keybind_active = obj
	}
}
