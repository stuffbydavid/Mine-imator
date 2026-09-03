/// tab_add_category(name, icon, script, show)
/// @arg name
/// @arg icon
/// @arg script
/// @arg show

function tab_add_category(name, icon, script, show)
{
	var cat = new_obj(obj_category);
	
	category[category_amount] = cat
	category_amount++
	
	with (cat)
	{
		id.name = name
		id.icon = icon
		id.script = script
		id.show = show
		
		enabled = true
		
		return id
	}
}
