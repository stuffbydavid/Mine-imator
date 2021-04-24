/// app_update_keybinds()

function app_update_keybinds()
{
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
