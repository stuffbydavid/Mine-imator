/// vbuffer_add_quad(pos1, pos2, pos3, pos4, tx1, tx2, tx3, tx4, [matrix])
/// @arg pos1
/// @arg pos2
/// @arg pos3
/// @arg pos4
/// @arg tx1
/// @arg tx2
/// @arg tx3
/// @arg tx4
/// @arg [matrix]

function vbuffer_add_quad(pos1, pos2, pos3, pos4, tx1, tx2, tx3, tx4, mat)
{
	var normal;
	
	// Transform points
	if (mat != null)
	{
		var newpoint, point, i;
		i = 0
		
		repeat(4)
		{
			point = argument[i]
			
			newpoint[X] = mat[@ 0] * point[@ X] + mat[@ 4] * point[@ Y] + mat[@ 8]  * point[@ Z] + mat[@ 12]
			newpoint[Y] = mat[@ 1] * point[@ X] + mat[@ 5] * point[@ Y] + mat[@ 9]  * point[@ Z] + mat[@ 13]
			newpoint[Z] = mat[@ 2] * point[@ X] + mat[@ 6] * point[@ Y] + mat[@ 10] * point[@ Z] + mat[@ 14]
			
			switch (i)
			{
				case 0: pos1 = newpoint; break;
				case 1: pos2 = newpoint; break;
				case 2: pos3 = newpoint; break;
				case 3: pos4 = newpoint; break;
			}
			
			i++
		}
	}
	
	// Calculate normal
	normal[X] = (pos1[@ Z] - pos2[@ Z]) * (pos3[@ Y] - pos2[@ Y]) - (pos1[@ Y] - pos2[@ Y]) * (pos3[@ Z] - pos2[@ Z])
	normal[Y] = (pos1[@ X] - pos2[@ X]) * (pos3[@ Z] - pos2[@ Z]) - (pos1[@ Z] - pos2[@ Z]) * (pos3[@ X] - pos2[@ X])
	normal[Z] = (pos1[@ Y] - pos2[@ Y]) * (pos3[@ X] - pos2[@ X]) - (pos1[@ X] - pos2[@ X]) * (pos3[@ Y] - pos2[@ Y])
	
	// Triangle 1
	vertex_add(pos1, normal, tx1)
	vertex_add(pos2, normal, tx2)
	vertex_add(pos3, normal, tx3)
	
	// Triangle 2
	vertex_add(pos3, normal, tx3)
	vertex_add(pos4, normal, tx4)
	vertex_add(pos1, normal, tx1)
}