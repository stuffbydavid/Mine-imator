/// model_part_fill_shape_vbuffer_map(part, vbuffermap, cachelist, alphamap, bend)
/// @arg part
/// @arg vbuffermap
/// @arg cachelist
/// @arg alphamap
/// @arg bend
/// @desc Clears and fills the given map with vbuffers for the 3D shapes, bent by a rotation vector.

function model_part_fill_shape_vbuffer_map(part, vbufmap, cachelist, alphamap, bend)
{
	// Clamp
	for (var i = X; i <= Z; i++)
		bend[X + i] = clamp(bend[X + i], part.bend_direction_min[i], part.bend_direction_max[i])
	
	if (part.shape_list = null)
		return 0
	
	// Reduce precision for cache storing
	bend[X] = snap(bend[X], 0.01)
	bend[Y] = snap(bend[Y], 0.01)
	bend[Z] = snap(bend[Z], 0.01)
	
	// Key we'll use for saving/reading cache "X,Y,Z"
	var key = string(bend[X]) + "," + string(bend[Y]) + "," + string(bend[Z]);
	
	// Fill list to prevent gaps
	if (ds_list_size(cachelist) < ds_list_size(part.shape_list))
	{
		for (var s = 0; s < ds_list_size(part.shape_list); s++)
			cachelist[|s] = null
	}
	
	var shape, bendkeymap, vbuffer;
	
	for (var s = 0; s < ds_list_size(part.shape_list); s++)
	{
		shape = part.shape_list[|s]
		bendkeymap = cachelist[|s]
		vbuffer = null
		
		// Use pre-existing cache (if it exists)
		if (bendkeymap != null && ds_map_exists(bendkeymap, key))
			vbuffer = bendkeymap[?key]
		else // Generate mesh
		{
			with (shape)
			{
				// Generate new mesh if needed
				if (type = "block" && bend_shape)
					vbuffer = model_shape_generate_block(bend)
				else if (type = "plane")
				{
					if (is3d)
					{
						if (ds_map_valid(alphamap))
							vbuffer = model_shape_generate_plane_3d(bend, alphamap[? id])
					}
					else if (bend_shape)
						vbuffer = model_shape_generate_plane(bend)
				}
			}
			
			// Save cache
			if (vbuffer != null)
			{
				if (bendkeymap = null)
					bendkeymap = ds_map_create()
				
				bendkeymap[? key] = vbuffer
			}
		}
		
		// Set default if no new mesh is generated
		if (vbuffer = null)
			vbuffer = shape.vbuffer_default
		
		// Set vbuffer
		vbufmap[? shape] = vbuffer
	}
}
