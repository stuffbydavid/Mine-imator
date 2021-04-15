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

var item, name, script, active, value, icon, side, tip, sprite, list;
item = argument[0]
name = argument[1]
script = argument[2]
active = argument[3]
value = argument[4]
icon = argument[5]
side = argument[6]
sprite = null
tip = name

if (argument_count > 7)
{
	tip = argument[7]
	sprite = argument[8]
}

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
