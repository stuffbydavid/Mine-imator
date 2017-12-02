/// vbuffer_create_sphere(radius, tex1, tex2, detail, invert)
/// @arg radius
/// @arg tex1
/// @arg tex2
/// @arg detail
/// @arg invert

var rad, tex1, tex2, detail, invert;
rad = argument0
tex1 = argument1
tex2 = argument2
detail = argument3
invert = argument4

vbuffer_start()

tex1[X] += 0.25
tex2[X] += 0.25

var i = 0;
while (i < 1)
{
	var ip, j;
	ip = i
	i += 1 / detail
	j = 0
	
	while (j < 1)
	{
		var jp;
		var n1x, n1y, n1z, n2x, n2y, n2z, n3x, n3y, n3z, n4x, n4y, n4z;
		var x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4;
		var texsize, texmid, n;
		jp = j
		j += 1 / (detail - 2)
		texsize = point2D_sub(tex2, tex1)
		texmid = point2D_add(tex1, vec2_mul(texsize, 1 / 2))
		n = negate(invert)
		
		n1x = sin(ip * pi * 2) * sin(jp * pi)
		n1y = -cos(ip * pi * 2) * sin(jp * pi)
		n1z = -cos(jp * pi)
		n2x = sin(ip * pi * 2) * sin(j * pi)
		n2y = -cos(ip * pi * 2) * sin(j * pi)
		n2z = -cos(j * pi)
		n3x = sin(i * pi * 2) * sin(jp * pi)
		n3y = -cos(i * pi * 2) * sin(jp * pi)
		n3z = -cos(jp * pi)
		n4x = sin(i * pi * 2) * sin(j * pi)
		n4y = -cos(i * pi * 2) * sin(j * pi)
		n4z = -cos(j * pi)
		
		x1 = n1x * rad
		y1 = n1y * rad
		z1 = n1z * rad
		x2 = n2x * rad
		y2 = n2y * rad
		z2 = n2z * rad
		x3 = n3x * rad
		y3 = n3y * rad
		z3 = n3z * rad
		x4 = n4x * rad
		y4 = n4y * rad
		z4 = n4z * rad
		
		if (jp > 0) 
		{
			if (invert)
			{
				vertex_add(x3, y3, z3, n3x * n, n3y * n, n3z * n, tex2[X] - i * texsize[X], texmid[Y] - n3z * (texsize[Y] / 2))
				vertex_add(x1, y1, z1, n1x * n, n1y * n, n1z * n, tex2[X] - ip * texsize[X], texmid[Y] - n1z * (texsize[Y] / 2))
				vertex_add(x4, y4, z4, n4x * n, n4y * n, n4z * n, tex2[X] - i * texsize[X], texmid[Y] - n4z * (texsize[Y] / 2))
			}
			else
			{
				vertex_add(x1, y1, z1, n1x * n, n1y * n, n1z * n, tex2[X] - ip * texsize[X], texmid[Y] - n1z * (texsize[Y] / 2))
				vertex_add(x3, y3, z3, n3x * n, n3y * n, n3z * n, tex2[X] - i * texsize[X], texmid[Y] - n3z * (texsize[Y] / 2))
				vertex_add(x4, y4, z4, n4x * n, n4y * n, n4z * n, tex2[X] - i * texsize[X], texmid[Y] - n4z * (texsize[Y] / 2))
			}
		}
		if (j < 1)
		{
			if (invert)
			{
				vertex_add(x4, y4, z4, n4x * n, n4y * n, n4z * n, tex2[X] - i * texsize[X], texmid[Y] - n4z * (texsize[Y] / 2))
				vertex_add(x1, y1, z1, n1x * n, n1y * n, n1z * n, tex2[X] - ip * texsize[X], texmid[Y] - n1z * (texsize[Y] / 2))
				vertex_add(x2, y2, z2, n2x * n, n2y * n, n2z * n, tex2[X] - ip * texsize[X], texmid[Y] - n2z * (texsize[Y] / 2))
			}
			else
			{
				vertex_add(x1, y1, z1, n1x * n, n1y * n, n1z * n, tex2[X] - ip * texsize[X], texmid[Y] - n1z * (texsize[Y] / 2))
				vertex_add(x4, y4, z4, n4x * n, n4y * n, n4z * n, tex2[X] - i * texsize[X], texmid[Y] - n4z * (texsize[Y] / 2))
				vertex_add(x2, y2, z2, n2x * n, n2y * n, n2z * n, tex2[X] - ip * texsize[X], texmid[Y] - n2z * (texsize[Y] / 2))
			}
		}
	}
}

return vbuffer_done()
