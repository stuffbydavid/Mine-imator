/// model_part_fill_shape_vbuffer_map(part, vbuffermap, cachelist, alphamap, bend)
/// @arg part
/// @arg vbuffermap
/// @arg alphamap
/// @arg bend
/// @desc Clears and fills the given map with vbuffers for the 3D shapes, bent by a rotation vector.

function model_part_fill_shape_vbuffer_map(part, vbufmap, cachelist, alphamap, bend)
{
	var isbent = !vec3_equals(bend, vec3(0));
	
	// Clamp
	for (var i = X; i <= Z; i++)
		bend[X + i] = clamp(bend[X + i], part.bend_direction_min[i], part.bend_direction_max[i])
	
	if (part.shape_list = null)
		return 0
	
	var key;
	bend[X] = snap(bend[X], 0.05)
	bend[Y] = snap(bend[Y], 0.05)
	bend[Z] = snap(bend[Z], 0.05)
	
	key = string(bend[X]) + "," + string(bend[Y]) + "," + string(bend[Z])
	
	// Bounding box info
	var boxdefault = true;
	bounding_box.reset()
	
	for (var s = 0; s < ds_list_size(part.shape_list); s++)
	{
		var usedcache = false;
		
		with (part.shape_list[|s])
		{
			if (ds_map_valid(cachelist[|s]) && ds_map_exists(cachelist[|s], key) && isbent)
			{
				var map = cachelist[|s];
				var bendcache = map[?key];
				vbufmap[? id] = bendcache[0]
				other.bounding_box.merge(bendcache[1])
				usedcache = true
				
				break
			}
			
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
			if (!usedcache)
			{
				var shapebox = new bbox();
				shapebox.copy_vbuffer()
				shapebox.mul_matrix(part.shape_list[|s].matrix)
				bounding_box.merge(shapebox)
			
				if (isbent)
				{
					if (!ds_map_valid(cachelist[|s]))
						cachelist[|s] = ds_map_create()
					
					cachelist[|s][? key] = [vbuffer_current, new bbox()]
				}
			}
		}
	}
}
