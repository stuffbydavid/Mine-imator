/// app_update_keybinds()

function app_update_keybinds()
{
	if (!(keyboard_check(vk_anykey) || keyboard_check_released(vk_anykey)))
		return 0
	
	var obj, check;
	
	for (var i = 0; i < e_keybind.amount; i++)
	{
		obj = keybinds_map[?i]
		
		check = keybind_check(obj.keybind)
		obj.released = (obj.active && !check)
		obj.pressed = (!obj.active && check)
		obj.active = check
	}
}
