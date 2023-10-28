/// list_item_add_action(item, name, script, active, value, icon, side, [tip, sprite])
/// @arg item
/// @arg name
/// @arg script
/// @arg active
/// @arg value
/// @arg icon
/// @arg side
/// @arg [tip
/// @arg sprite]

function list_item_add_action(item, name, script, active, value, icon, side, tip = undefined, sprite = null)
{
	if (is_undefined(tip))
		tip = name
	
	var list;
	
	with (item)
	{
		if (side = "right")
		{
			if (actions_right = null)
				actions_right = ds_list_create()
			
			list = actions_right
		}
		else
		{
			if (actions_left = null)
				actions_left = ds_list_create()
			
			list = actions_left
		}
	}
	
	ds_list_add(list, name)
	ds_list_add(list, active)
	ds_list_add(list, value)
	ds_list_add(list, icon)
	ds_list_add(list, script)
	ds_list_add(list, tip)
	ds_list_add(list, sprite)
}
