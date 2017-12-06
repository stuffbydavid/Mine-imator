/// model_part_fill_shape_vbuffer_map(part, vbuffermap, alphamap, angle)
/// @arg part
/// @arg vbuffermap
/// @arg alphamap
/// @arg angle
/// @desc Clears and fills the given map with vbuffers for the 3D shapes, bent by an angle.

var part, vbufmap, alphamap, angle;
part = argument0
vbufmap = argument1
alphamap = argument2
angle = argument3

if (part.shape_list = null)
	return 0
	
for (var s = 0; s < ds_list_size(part.shape_list); s++)
{
	with (part.shape_list[|s])
	{
		if (type = "block" && angle != 0)
			vbufmap[?id] = model_shape_generate_block(angle)
		else if (type = "plane")
		{
			if (is3d)
				vbufmap[?id] = model_shape_generate_plane_3d(angle, alphamap[?id])
			else if (angle != 0)
				vbufmap[?id] = model_shape_generate_plane(angle)
		}
	}
}