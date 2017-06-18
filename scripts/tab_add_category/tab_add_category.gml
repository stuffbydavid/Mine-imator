/// tab_add_category(name, script, show)
/// @arg name
/// @arg script
/// @arg show

var cat = new(obj_category);

category[category_amount] = cat
category_amount++

with (cat)
{
	name = argument0
	script = argument1
	show = argument2
	enabled = true

	return id
}