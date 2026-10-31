/// @desc Adds a triangle from real-valued positions and texture coordinates.

function vbuffer_add_triangle_real(x1, y1, z1, x2, y2, z2, x3, y3, z3, tx1, ty1, tx2, ty2, tx3, ty3, invert = false, matrix = null)
{
	if (matrix != null)
	{
		var mat, px1, py1, pz1, px2, py2, pz2, px3, py3, pz3;
		mat = matrix
		
		px1 = mat[@ 0] * x1 + mat[@ 4] * y1 + mat[@ 8] * z1 + mat[@ 12]
		py1 = mat[@ 1] * x1 + mat[@ 5] * y1 + mat[@ 9] * z1 + mat[@ 13]
		pz1 = mat[@ 2] * x1 + mat[@ 6] * y1 + mat[@ 10] * z1 + mat[@ 14]

		px2 = mat[@ 0] * x2 + mat[@ 4] * y2 + mat[@ 8] * z2 + mat[@ 12]
		py2 = mat[@ 1] * x2 + mat[@ 5] * y2 + mat[@ 9] * z2 + mat[@ 13]
		pz2 = mat[@ 2] * x2 + mat[@ 6] * y2 + mat[@ 10] * z2 + mat[@ 14]

		px3 = mat[@ 0] * x3 + mat[@ 4] * y3 + mat[@ 8] * z3 + mat[@ 12]
		py3 = mat[@ 1] * x3 + mat[@ 5] * y3 + mat[@ 9] * z3 + mat[@ 13]
		pz3 = mat[@ 2] * x3 + mat[@ 6] * y3 + mat[@ 10] * z3 + mat[@ 14]

		x1 = px1; y1 = py1; z1 = pz1;
		x2 = px2; y2 = py2; z2 = pz2;
		x3 = px3; y3 = py3; z3 = pz3;
	}

	// Calculate normal
	var nx, ny, nz;
	nx = (z1 - z2) * (y3 - y2) - (y1 - y2) * (z3 - z2)
	ny = (x1 - x2) * (z3 - z2) - (z1 - z2) * (x3 - x2)
	nz = (y1 - y2) * (x3 - x2) - (x1 - x2) * (y3 - y2)

	// Invert
	if (invert)
	{
		var swapx, swapy, swapz;
		swapx = x1; swapy = y1; swapz = z1;
		x1 = x2; y1 = y2; z1 = z2;
		x2 = swapx; y2 = swapy; z2 = swapz;
		
		var swaptx, swapty;
		swaptx = tx1; swapty = ty1;
		tx1 = tx2; ty1 = ty2;
		tx2 = swaptx; ty2 = swapty;
		
		nx *= -1
		ny *= -1
		nz *= -1
	}

	var normallength = point_distance_3d(0, 0, 0, nx, ny, nz);
	if (normallength != 0)
	{
		nx /= normallength
		ny /= normallength
		nz /= normallength
	}

	vertex_add_real(x1, y1, z1, nx, ny, nz, tx1, ty1)
	vertex_add_real(x2, y2, z2, nx, ny, nz, tx2, ty2)
	vertex_add_real(x3, y3, z3, nx, ny, nz, tx3, ty3)
}
