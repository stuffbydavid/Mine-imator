/// model_part_fill_shape_vbuffer_map(part, vbuffermap, angle, resource, texturenamemap)
/// @arg part
/// @arg vbuffermap
/// @arg angle
/// @arg resource
/// @arg texturenamemap
/// @desc Clears and fills the given maps with vbuffers for the 3D shapes,
///		  with the given resource selected as a texture and bent by an angle.

var part, vbufmap, angle, res, texnamemap;
part = argument0
vbufmap = argument1
angle = argument2
res = argument3
texnamemap = argument4

if (part.shape_list = null)
	return 0
	
var parttexname = model_part_get_texture_name(part, texnamemap);
for (var s = 0; s < ds_list_size(part.shape_list); s++)
{
	with (part.shape_list[|s])
	{
		if (type = "block" && angle != 0)
			vbufmap[?id] = model_shape_generate_block(angle)
		else if (type = "plane")
		{
			if (is3d)
			{
				// Get texture (shape texture overrides part texture)
				var shapetexname = parttexname;
				if (texture_name != "")
					shapetexname = texture_name
			
				var tex;
				with (res)
					tex = res_get_model_texture(shapetexname)
				
				if (tex != null)
					vbufmap[?id] = model_shape_generate_plane_3d(tex, angle)
			}
			else if (angle != 0)
				vbufmap[?id] = model_shape_generate_plane(angle)
		}
	}
}