/// new_videotemplate(name, width, height)
/// @arg name
/// @arg width
/// @arg height

function new_videotemplate(name, w, h)
{
	with (new_obj(obj_videotemplate))
	{
		id.name = name
		id.width = w
		id.height = h
		
		return id
	}
}
