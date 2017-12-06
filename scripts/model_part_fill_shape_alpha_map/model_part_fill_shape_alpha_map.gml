/// model_part_fill_shape_alpha_map(part, alphamap, resource, texturenamemap)
/// @arg part
/// @arg alphamap
/// @arg resource
/// @arg texturenamemap
/// @desc Fills the given maps with alpha values for the 3D planes,
///		  with the given resource selected as a texture.

var part, alphamap, res, texnamemap;
part = argument0
alphamap = argument1
res = argument2
texnamemap = argument3

if (part.shape_list = null)
	return 0
	
var parttexname = model_part_get_texture_name(part, texnamemap);
for (var s = 0; s < ds_list_size(part.shape_list); s++)
{
	with (part.shape_list[|s])
	{
		if (type = "plane" && is3d)
		{
			// Get texture (shape texture overrides part texture)
			var shapetexname = parttexname;
			if (texture_name != "")
				shapetexname = texture_name
			
			var tex;
			with (res)
				tex = res_get_model_texture(shapetexname)
				
			if (tex != null)
			{
				var texsize = point3D_sub(to_noscale, from_noscale);
					
				// Generate array with the alpha values of the texture
				var surf, alpha, samplesize;
				samplesize = vec2(ceil(texsize[X]), ceil(texsize[Z]))
				surf = surface_create(samplesize[X], samplesize[Y])
				draw_texture_start()
				surface_set_target(surf)
				{
					draw_clear_alpha(c_black, 0)
					draw_texture_part(tex, 0, 0, uv[X], uv[Y], samplesize[X], samplesize[Y])
				}
				surface_reset_target()
				draw_texture_done()
				alphamap[?id] = surface_get_alpha_array(surf)
				surface_free(surf)
			}
		}
	}
}