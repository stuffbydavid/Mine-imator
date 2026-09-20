/// keybinds_update_match()
/// @desc Updates match errors in keybinds

function keybinds_update_match()
{
	with (obj_keybind)
	{
		match_error = false
		
		with (obj_keybind)
		{
			if (id = other.id)
				continue
			
			// Don't show matching key error with unbound keys
			if (keybind[e_keybind_key.CHAR] = vk_nokey)
				continue
			
			if (array_equals(keybind, other.keybind) && (navigation = other.navigation))
			{
				other.match_error = true
				break
			}
		}
	}
}
