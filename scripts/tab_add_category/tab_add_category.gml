/// tab_add_category(name, script, show)
/// @arg name
/// @arg script
/// @arg show

function tab_add_category(name, script, show)
{
	var cat = new_obj(obj_category);
	
	category[category_amount] = cat
	category_amount++
	
	with (cat)
	{
		id.name = argument0
		id.script = argument1
		id.show = argument2
		enabled = true
		
		return id
	}
}
