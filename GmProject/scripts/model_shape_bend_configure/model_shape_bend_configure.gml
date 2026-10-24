/// @desc Configures a static bendable mesh with per-object shader parameters
function model_shape_bend_configure(kind, sharpbend)
{
	var pivot = vec3(0);
	if (bend_part = e_part.LEFT || bend_part = e_part.RIGHT)
		pivot[X] = bend_offset - position[X]
	else if (bend_part = e_part.BACK || bend_part = e_part.FRONT)
		pivot[Y] = bend_offset - position[Y]
	else
		pivot[Z] = bend_offset - position[Z]

	var direction = vec3(0);
	var sharpaxis = -1;
	for (var i = X; i <= Z; i++)
	{
		direction[i] = bend_axis[i] ? (bend_invert[i] ? -1 : 1) : 0
		if (sharpbend && bend_axis[i])
			sharpaxis = i
	}
	// Extruded planes use texture-specific topology rather than the default flat preview
	var zerobuffer = (kind != 3 && has_vertex_offsets && vbuffer_default != null) ? vbuffer_default : 0;
	var minimum = vec3(bend_direction_min[X], bend_direction_min[Y], bend_direction_min[Z]);
	var maximum = vec3(bend_direction_max[X], bend_direction_max[Y], bend_direction_max[Z]);
	vertex_bend_configure(vbuffer_current, pivot, minimum, maximum, direction, kind, sharpaxis, zerobuffer)
}
