function tab_add_category(name, icon, script, show)
{
	var cat = new_obj(obj_category);
	
	category[category_amount] = cat
	category_amount++
	
	with (cat)
	{
		self.name = name
		self.icon = icon
		self.script = script
		self.show = show
		
		enabled = true
		
		return id
	}
}
