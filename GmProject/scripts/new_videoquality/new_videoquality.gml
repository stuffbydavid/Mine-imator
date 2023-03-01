/// new_videoquality(name, bitrate)
/// @arg name
/// @arg bitrate

function new_videoquality(name, bitrate)
{
	with (new_obj(obj_videoquality))
	{
		id.name = name
		id.bit_rate = bitrate
		
		return id
	}
}
