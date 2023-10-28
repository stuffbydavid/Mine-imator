/// model_part_fill_shape_alpha_map(part, alphamap, resource, texturenamemap, shapetexnamemap)
/// @arg part
/// @arg alphamap
/// @arg resource
/// @arg texturenamemap
/// @arg shapetexnamemap
/// @desc Fills the given maps with alpha values for the 3D planes,
/// with the given resource selected as a texture.

function model_part_fill_shape_alpha_map(part, alphamap, res, texnamemap, shapetexnamemap)
{
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
				
				// Change texture if name is in shape texture map
				if (shapetexnamemap != null)
				{
					var maptexname = shapetexnamemap[? description];
					if (!is_undefined(maptexname))
						shapetexname = maptexname
				}
				
				var tex;
				with (res)
					tex = res_get_model_texture(shapetexname)
				
				if (tex != null)
				{
					// Define texture pixels to use
					var tw, th, texsize, texsizeuv, texuv, samplepos, samplesize;
					tw = texture_width(tex)
					th = texture_height(tex)
					texsize = point3D_sub(to_noscale, from_noscale)
					texsizeuv = vec2_div(vec2(texsize[X], texsize[Z]), texture_size)
					texuv = vec2_div(uv, texture_size)
					samplepos = point2D(ceil(texuv[X] * tw), ceil(texuv[Y] * th))
					samplesize = vec2(ceil(texsizeuv[X] * tw), ceil(texsizeuv[Y] * th))
					
					// Generate array with the alpha values of the texture
					var surf = surface_create(samplesize[X], samplesize[Y])
					draw_texture_start()
					surface_set_target(surf)
					{
						draw_clear_alpha(c_black, 0)
						draw_texture_part(tex, 0, 0, samplepos[X], samplepos[Y], samplesize[X], samplesize[Y])
					}
					surface_reset_target()
					draw_texture_done()
					alphamap[?id] = surface_get_alpha_array(surf)
					surface_free(surf)
				}
			}
		}
	}
}
