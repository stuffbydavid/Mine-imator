/// @desc Creates the shape mesh of a path from its sampled points, called by the path.
/// CppGen ArrRef path_table
/// CppGen matrix pathframea
/// CppGen matrix pathframeb
/// CppGen vec pathpointa
/// CppGen vec pathpointb
/// CppGen vec pathuv1
/// CppGen vec pathuv2
/// CppGen vec pathuv3
/// CppGen vec pathuv4

function vbuffer_create_path(path, small = false)
{
	var closed, rail, radius, invert, detail, mapped, texlength, smoothsegments, smoothring;
	closed = path.path_closed
	rail = path.path_shape = "flat"
	radius = path.path_shape_radius
	invert = path.path_shape_invert
	detail = path.path_shape_detail
	mapped = path.path_shape_tex_mapped
	texlength = path.path_shape_tex_length
	smoothsegments = path.path_shape_smooth_segments
	smoothring = path.path_shape_smooth_ring

	// Create mesh for clicking path(for selection) where a shape isn't set to be used in timeline
	if (small)
	{
		radius = 1
		detail = 4
		rail = false
		invert = false
	}

	vbuffer_start()

	// Compile coordinate frames
	var frames, pointcount;
	pointcount = array_length(path_table)

	for (var i = 0; i < pointcount; i++)
		frames[i] = matrix_create_rotate_to(vec3(path_table[i][PATH_TANGENT_X], path_table[i][PATH_TANGENT_Y], path_table[i][PATH_TANGENT_Z]),
											vec3(path_table[i][PATH_NORMAL_X], path_table[i][PATH_NORMAL_Y], path_table[i][PATH_NORMAL_Z]))

	var p1, p2, p3, p4;
	var n1, n2, n3, n4, nflatp, nflat;
	var nn1, nn2, nn3, nn4;
	var pathuv1, pathuv2, pathuv3, pathuv4;
	var jp, j;
	var ringp;
	var length, plength;
	var radiusa, radiusb, pathframea, pathframeb, pathpointa, pathpointb;
	length = 0
	plength = 0

	for (var i = 0; i < pointcount - 1; i++)
	{
		// Read the segment's points and frames once instead of per ring vertex
		pathframea = frames[i]
		pathframeb = frames[i + 1]
		pathpointa = point3D(path_table[i][X], path_table[i][Y], path_table[i][Z])
		pathpointb = point3D(path_table[i + 1][X], path_table[i + 1][Y], path_table[i + 1][Z])
		radiusa = radius * path_table[i][4]
		radiusb = radius * path_table[i + 1][4]

		if (!rail)
		{
			jp = 0
			j = 1/detail
		}
		else
			jp = .5 // Left side of rail

		ringp = vec3(cos(jp * pi * 2), 0, -sin(jp * pi * 2))

		plength = length
		length += point3D_distance(pathpointa, pathpointb)

		// p1 - current point's segment
		n1 = vec3_normalize(vec3_mul_matrix(ringp, pathframea))
		p1 = point3D_add(vec3_mul(n1, radiusa), pathpointa)

		// p3 - next point's segment
		n3 = vec3_normalize(vec3_mul_matrix(ringp, pathframeb))
		p3 = point3D_add(vec3_mul(n3, radiusb), pathpointb)

		// Offset before loop
		jp = 0
		j = 0

		while (j < 1)
		{
			if (!rail)
			{
				jp = j
				j += 1 / detail
			}
			else
				j = 0 // Right side of rail

			ringp = vec3(cos(j * pi * 2), 0, -sin(j * pi * 2))

			// Next segment
			n2 = vec3_normalize(vec3_mul_matrix(ringp, pathframea))
			p2 = point3D_add(vec3_mul(n2, radiusa), pathpointa)

			// Next segment
			n4 = vec3_normalize(vec3_mul_matrix(ringp, pathframeb))
			p4 = point3D_add(vec3_mul(n4, radiusb), pathpointb)

			if (rail)
			{
				pathuv1 = vec2(0, plength / texlength)
				pathuv2 = vec2(1, plength / texlength)
				pathuv3 = vec2(0, length / texlength)
				pathuv4 = vec2(1, length / texlength)

				n1 = vec3(pathframea[8], pathframea[9], pathframea[10])
				n2 = n1
				n3 = vec3(pathframeb[8], pathframeb[9], pathframeb[10])
				n4 = n3
			}
			else
			{
				pathuv1 = vec2(jp, plength / texlength)
				pathuv2 = vec2(j, plength / texlength)
				pathuv3 = vec2(jp, length / texlength)
				pathuv4 = vec2(j, length / texlength)
			}

			if (mapped)
			{
				pathuv1[X] /= 3
				pathuv2[X] /= 3
				pathuv3[X] /= 3
				pathuv4[X] /= 3
			}

			nn1 = n1
			nn2 = n2
			nn3 = n3
			nn4 = n4

			// Invert normals
			if (invert)
			{
				nn1 = vec3_mul(nn1, -1)
				nn2 = vec3_mul(nn2, -1)
				nn3 = vec3_mul(nn3, -1)
				nn4 = vec3_mul(nn4, -1)
			}

			// Smooth segments, flat radius
			if (smoothsegments && !smoothring)
			{
				nflatp = vec3_normalize(vec3_add(nn1, nn2))
				nflat = vec3_normalize(vec3_add(nn3, nn4))
				nn1 = nflatp
				nn2 = nflatp
				nn3 = nflat
				nn4 = nflat
			}
			else if (!smoothsegments && smoothring) // Flat segments, smooth radius
			{
				nflatp = vec3_normalize(vec3_add(nn1, nn3))
				nflat = vec3_normalize(vec3_add(nn2, nn4))
				nn1 = nflatp
				nn2 = nflat
				nn3 = nflatp
				nn4 = nflat
			}
			else if (!smoothsegments && !smoothring) // Flat
			{
				nflat = vec3_normalize(vec3_add(vec3_add(vec3_add(nn1, nn2), nn3), nn4))
				nn1 = nflat
				nn2 = nflat
				nn3 = nflat
				nn4 = nflat
			}

			if (invert)
			{
				vbuffer_add_triangle(p2, p1, p4, pathuv2, pathuv1, pathuv4, nn2, nn1, nn4)
				vbuffer_add_triangle(p1, p3, p4, pathuv1, pathuv3, pathuv4, nn1, nn3, nn4)
			}
			else
			{
				vbuffer_add_triangle(p4, p1, p2, pathuv4, pathuv1, pathuv2, nn4, nn1, nn2)
				vbuffer_add_triangle(p4, p3, p1, pathuv4, pathuv3, pathuv1, nn4, nn3, nn1)
			}

			if (rail)
				break

			// Fill ends of tube
			if (!closed)
			{
				pathuv1 = vec2((cos((jp + .25) * pi * 2) + 1)/2, (sin((jp + .25) * pi * 2) + 1)/2)
				pathuv2 = vec2((cos((j + .25) * pi * 2) + 1)/2, (sin((j + .25) * pi * 2) + 1)/2)
				pathuv3 = vec2(.5, .5)

				if (mapped)
				{
					pathuv1[X] = (pathuv1[X] / 3) + (1/3)
					pathuv2[X] = (pathuv2[X] / 3) + (1/3)
					pathuv3[X] = (pathuv3[X] / 3) + (1/3)
				}

				// Beginning
				if (i = 0)
				{
					if (invert)
						vbuffer_add_triangle(p2, pathpointa, p1, pathuv2, pathuv3, pathuv1)
					else
						vbuffer_add_triangle(p1, pathpointa, p2, pathuv1, pathuv3, pathuv2)
				}

				// End
				if (i = (pointcount - 2))
				{
					if (mapped)
					{
						pathuv1[X] += (1/3)
						pathuv2[X] += (1/3)
						pathuv3[X] += (1/3)
					}

					if (invert)
						vbuffer_add_triangle(p3, pathpointb, p4, pathuv1, pathuv3, pathuv2)
					else
						vbuffer_add_triangle(p4, pathpointb, p3, pathuv2, pathuv3, pathuv1)
				}
			}

			p1 = p2
			p3 = p4
			n1 = n2
			n3 = n4
		}

	}

	return vbuffer_done()
}
