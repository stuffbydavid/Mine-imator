/// @arg name
/// @arg width
/// @arg height

function new_videotemplate(name, w, h)
{
	with (new_obj(obj_videotemplate))
	{
		self.name = name
		self.width = w
		self.height = h
		
		return id
	}
}
