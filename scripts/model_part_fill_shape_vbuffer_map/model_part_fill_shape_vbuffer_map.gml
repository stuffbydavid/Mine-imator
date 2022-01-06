/// model_part_fill_shape_vbuffer_map(part, vbuffermap, alphamap, bend)
/// @arg part
/// @arg vbuffermap
/// @arg alphamap
/// @arg bend
/// @desc Clears and fills the given map with vbuffers for the 3D shapes, bent by a rotation vector.

function model_part_fill_shape_vbuffer_map(part, vbufmap, alphamap, bend)
{
	var isbent = !vec3_equals(bend, vec3(0));
	
	// Clamp
	for (var i = X; i <= Z; i++)
		bend[X + i] = clamp(bend[X + i], part.bend_direction_min[i], part.bend_direction_max[i])
	
	if (part.shape_list = null)
		return 0
	
	// Bounding box info
	var boxdefault = true;
	bounding_box.reset()
	
	for (var s = 0; s < ds_list_size(part.shape_list); s++)
	{
		with (part.shape_list[|s])
		{
			boxdefault = true
			
			vbufmap[? id] = vbuffer_default
			if (type = "block" && isbent && bend_shape)
			{
				vbufmap[? id] = model_shape_generate_block(bend)
				boxdefault = false
			}
			else if (type = "plane")
			{
				if (is3d)
				{
					if (ds_map_valid(alphamap))
					{
						vbufmap[? id] = model_shape_generate_plane_3d(bend, alphamap[?id])
						boxdefault = false
					}
				}
				else if (isbent && bend_shape)
				{
					vbufmap[? id] = model_shape_generate_plane(bend)
					boxdefault = false
				}
			}
		}
		
		if (boxdefault)
			bounding_box.merge(part.shape_list[|s].bounding_box_default)
		else
		{
			var shapebox = new bbox();
			shapebox.copy_vbuffer()
			shapebox.mul_matrix(part.shape_list[|s].matrix)
			bounding_box.merge(shapebox)
			delete shapebox
		}
	}
}
