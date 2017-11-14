/// model_part_get_plane_vbuffer_map(part, vbuffermap, alphaarraymap, resource, texturenamemap)
/// @arg part
/// @arg vbuffermap
/// @arg alphaarraymap
/// @arg resource
/// @arg texturenamemap
/// @desc Clears and fills the given maps with vbuffers and alpha values for the 3D planes,
///		  with the given resource selected as a texture.

var part, vbufmap, alphaarrmap, res, texnamemap;
part = argument0
vbufmap = argument1
alphaarrmap = argument2
res = argument3
texnamemap = argument4

if (part.shape_list = null)
	return 0
	
var parttexname = model_part_get_texture_name(part, texnamemap);

// Create vertex buffer for each 3D plane
draw_texture_start()
for (var s = 0; s < ds_list_size(part.shape_list); s++)
{
	with (part.shape_list[|s])
	{
		if (type != "plane" || !is3d)
			continue
			
		// Get texture (shape texture overrides part texture)
		var shapetexname = parttexname;
		if (texture_name != "")
			shapetexname = texture_name
				
		var tex, texsize;
		with (res)
			tex = res_get_model_texture(shapetexname)
				
		if (tex = null)
			continue
		
		vertex_brightness = color_brightness
		
		// Create surface from texture
		var surf, texsize;
		texsize = vec2(to_noscale[X] - from_noscale[X], to_noscale[Z] - from_noscale[Z])
		surf = surface_create(texsize[X], texsize[Y])
		render_set_culling(false)
		surface_set_target(surf)
		{
			if (texture_mirror)
				draw_texture_part(tex, texsize[X], 0, uv[X], uv[Y], texsize[X], texsize[Y], -1, 1)
			else
				draw_texture_part(tex, 0, 0, uv[X], uv[Y], texsize[X], texsize[Y])
		}
		surface_reset_target()
		render_set_culling(true)
		
		alphaarrmap[?id] = surface_get_alpha_array(surf)
		
		var vbufarr = array(null, null);
		if (bend_mode != e_shape_bend.BEND || bend_part = null || bend_part = e_part.FRONT || bend_part = e_part.BACK) // Bend deactivated or invalid half
		{
			// Generate 3D pixels
			vbufarr[0] = vbuffer_start()
			vbuffer_add_pixels(alphaarrmap[?id], from, texsize[Y] * scale[Z], array_copy_1d(uv), texsize, vec2_div(vec2(1), texture_size), scale, vec2(0, 0), vec2(0, 0), texture_mirror, color_blend, color_alpha)
			vbuffer_done()
		}
		else
		{
			var pos, bendoff, texoff;
		
			if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				texoff = bendoff / scale[Z]
			
				// Lower
				if (bend_part = e_part.UPPER)
				{
					pos = from
					vbufarr[0] = vbuffer_start()
				}
				else
				{
					pos = point3D(from[X], from[Y], -bendoff)
					vbufarr[1] = vbuffer_start()
				}
				vbuffer_add_pixels(alphaarrmap[?id], pos, bendoff, vec2(uv[X], uv[Y] + (texsize[Y] - texoff)), texsize, vec2_div(vec2(1), texture_size), scale, vec2(0, texsize[Y] - texoff), vec2(0, texoff), texture_mirror, color_blend, color_alpha)
				vbuffer_done()
		
				// Upper
				if (bend_part = e_part.UPPER)
				{
					pos = point3D(from[X], from[Y], 0)
					vbufarr[1] = vbuffer_start()
				}
				else
				{
					pos = point3D(from[X], from[Y], from[Z] + bendoff)
					vbufarr[0] = vbuffer_start()
				}
				vbuffer_add_pixels(alphaarrmap[?id], pos, texsize[Y] * scale[Z] - bendoff, array_copy_1d(uv), texsize, vec2_div(vec2(1), texture_size), scale, vec2(0, 0), vec2(0, -texoff), texture_mirror, color_blend, color_alpha)
				vbuffer_done()
			}
			else // Right or Left
			{
				bendoff = (bend_offset - position[X]) - from[X]
				texoff = bendoff / scale[X]
			
				// Left
				if (bend_part = e_part.RIGHT)
				{
					pos = from
					vbufarr[0] = vbuffer_start()
				}
				else
				{
					pos = point3D( -bendoff, from[Y], from[Z])
					vbufarr[1] = vbuffer_start()
				}
				vbuffer_add_pixels(alphaarrmap[?id], pos, texsize[Y], array_copy_1d(uv), texsize, vec2_div(vec2(1), texture_size), scale, vec2(0, 0), vec2(-(texsize[X] - texoff), 0), texture_mirror, color_blend, color_alpha)
				vbuffer_done()
		
				// Right
				if (bend_part = e_part.RIGHT)
				{
					pos = point3D(0, from[Y], from[Z])
					vbufarr[1] = vbuffer_start()
				}
				else
				{
					pos = point3D(from[X] + bendoff, from[Y], from[Z])
					vbufarr[0] = vbuffer_start()
				}
				vbuffer_add_pixels(alphaarrmap[?id], pos, texsize[Y], vec2(uv[X] + texoff, uv[Y]), texsize, vec2_div(vec2(1), texture_size), scale, vec2(texoff, 0), vec2(-texoff, 0), texture_mirror, color_blend, color_alpha)
				vbuffer_done()
			}
		}
	
		vbufmap[?id] = vbufarr
		vertex_brightness = 0
	}
}
draw_texture_done()