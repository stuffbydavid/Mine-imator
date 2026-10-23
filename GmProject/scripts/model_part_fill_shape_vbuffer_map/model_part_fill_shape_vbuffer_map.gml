/// @desc Clears and fills the given map with vbuffers for the 3D shapes, bent by a rotation vector.
/// @arg part
/// @arg vertexbuffermap
/// @arg alphamap
/// @arg bend
/// @arg [normaltextures]

function model_part_fill_shape_vbuffer_map(part, vbufmap, alphamap, bend, normaltextures = null)
{
	// Clamp
	for (var i = X; i <= Z; i++)
		bend[X + i] = clamp(bend[X + i], part.bend_direction_min[i], part.bend_direction_max[i])
	
	if (part.shape_list = null)
		return 0
	
	var isbent = !vec3_equals(bend, vec3(0));
	
	for (var s = 0; s < ds_list_size(part.shape_list); s++)
	{
		with (part.shape_list[|s])
		{
			var oldvbuf = vbufmap[? id];
			vbufmap[? id] = vbuffer_default

			var sharpbend = app.project_bend_style = "blocky" && bend_size = null &&
				((bend_axis[X] && !bend_axis[Y] && !bend_axis[Z]) ||
				(!bend_axis[X] && bend_axis[Y] && !bend_axis[Z]) ||
				(!bend_axis[X] && !bend_axis[Y] && bend_axis[Z]));
			var gpubend = is_cpp() && is_array(normaltextures) && s < array_length(normaltextures) &&
				normaltextures[s] = null && type = "block" && bend_shape && bend_part != null &&
				!sharpbend && !has_vertex_offsets && (bend_size = null || bend_size > 0) &&
				(wind_wave = e_vertex_wave.NONE || (wind_wave_zmin = null && wind_wave_zmax = null));

			if (gpubend && !isbent)
				gpubend = !is_undefined(oldvbuf) && oldvbuf != null && vbuffer_has_model_bend(oldvbuf)
			
			// Generate new mesh if needed
			if (gpubend)
			{
				var profile = debug_profiler_begin("GPU bend preparation");
				var vbuf = oldvbuf;
				if (is_undefined(vbuf) || vbuf = null || !vbuffer_has_model_bend(vbuf))
					vbuf = model_shape_generate_block(bend, true)

				var axis, pivot, segaxis, invangle, bendsize, direction;
				segaxis = Z
				if (bend_part = e_part.LEFT || bend_part = e_part.RIGHT)
					segaxis = X
				else if (bend_part = e_part.BACK || bend_part = e_part.FRONT)
					segaxis = Y

				axis = vec3(0)
				axis[segaxis] = 1
				pivot = vec3(0)
				pivot[segaxis] = bend_offset - position[segaxis]
				invangle = bend_part = e_part.LOWER || bend_part = e_part.BACK || bend_part = e_part.LEFT
				bendsize = (bend_size = null ? (app.project_bend_style = "realistic" ? 4 : 1) : bend_size)
				direction = vec3(bend_axis[X] * negate(bend_invert[X]),
					bend_axis[Y] * negate(bend_invert[Y]), bend_axis[Z] * negate(bend_invert[Z]))

				vbuffer_set_model_bend(vbuf, bend,
					matrix_build(0, 0, 0, rotation[X], rotation[Y], rotation[Z], 1, 1, 1),
					pivot, axis, [from[segaxis], pivot[segaxis] - bendsize / 2, bendsize, invangle],
					bend_direction_min, bend_direction_max, direction)
				vbufmap[? id] = vbuf
				debug_profiler_end("GPU bend preparation", profile)
			}
			else if (type = "block" && bend_shape && isbent)
			{
				var profile = debug_profiler_begin("CPU mesh generation");
				vbufmap[? id] = model_shape_generate_block(bend)
				debug_profiler_end("CPU mesh generation", profile)
			}
			else if (type = "plane")
			{
				if (is3d)
				{
					if (ds_map_valid(alphamap))
					{
						var profile = debug_profiler_begin("CPU mesh generation");
						vbufmap[? id] = model_shape_generate_plane_3d(bend, alphamap[? id])
						debug_profiler_end("CPU mesh generation", profile)
					}
				}
				else if (isbent && bend_shape)
				{
					var profile = debug_profiler_begin("CPU mesh generation");
					vbufmap[? id] = model_shape_generate_plane(bend)
					debug_profiler_end("CPU mesh generation", profile)
				}
			}

			if (!is_undefined(oldvbuf) && oldvbuf != null && oldvbuf != vbuffer_default && oldvbuf != vbufmap[? id])
				vbuffer_destroy(oldvbuf)
		}
	}
}
