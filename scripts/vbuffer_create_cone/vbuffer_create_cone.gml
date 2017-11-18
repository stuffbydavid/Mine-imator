/// vbuffer_create_cone(radius, texcoord1, texcoord2, texhorflip, texverflip, detail, closed, invert, mapped)
/// @arg radius
/// @arg texcoord1
/// @arg texcoord2
/// @arg texhorflip
/// @arg texverflip
/// @arg detail
/// @arg closed
/// @arg invert
/// @arg mapped

var rad, tex1, tex2, thflip, tvflip, detail, closed, invert, mapped;
rad = argument0
tex1 = argument1
tex2 = argument2
thflip = argument3
tvflip = argument4
detail = argument5
closed = argument6
invert = argument7
mapped = argument8

vbuffer_start()

tex1[X] += 0.25
tex2[X] += 0.25

var i = 0;
while (i < 1)
{
	var ip;
	var n1x, n1y, n2x, n2y;
	var x1, y1, x2, y2;
	var texsize, texmid;
	ip = i
	i += 1 / detail
	texsize = point2D_sub(tex2, tex1)
	texmid = point2D_add(tex1, vec2_mul(texsize, 1 / 2))
	
	n1x = cos(ip * pi * 2)
	n1y = -sin(ip * pi * 2)
	n2x = cos(i * pi * 2)
	n2y = -sin(i * pi * 2)
	x1 = n1x * rad
	y1 = n1y * rad
	x2 = n2x * rad
	y2 = n2y * rad
	
	// Invert normals
	if (invert)
	{
		n1x *= -1
		n1y *= -1
		n2x *= -1
		n2y *= -1
	}
	
	if (mapped)
	{
		texsize = vec2(0.5 * thflip, tvflip)
		texmid[Y] = texsize[Y] / 2
	}
	
	if (closed)
	{
		if (mapped)
			texmid[X] = 3 / 4
			
		// Bottom
		vbuffer_add_triangle(0, 0, -rad, x1, y1, -rad, x2, y2, -rad, 
							texmid[X], texmid[Y], 
							texmid[X] + cos(ip * pi * 2) * (texsize[X] / 2), texmid[Y] + sin(ip * pi * 2) * (texsize[Y] / 2), 
							texmid[X] + cos(i * pi * 2) * (texsize[X] / 2), texmid[Y] + sin(i * pi * 2) * (texsize[Y] / 2), c_white, 1, invert)
	}
	
	// Sides
	if (mapped)
	{
		texmid[X] = 1 / 4
		tex1 = point2D(0, 0)
		tex2 = point2D(abs(texsize[X]), abs(texsize[Y]))
		
		if (thflip < 0)
		{
			var tmp = tex1[X];
			tex1[X] = tex2[X]
			tex2[X] = tmp
		}
		
		if (tvflip < 0)
		{
			var tmp = tex1[Y];
			tex1[Y] = tex2[Y]
			tex2[Y] = tmp
		}
	}
	
	if (invert)
	{
		vertex_add(x2, y2, -rad, n2x, n2y, 0, tex1[X] + texsize[X] * i, tex1[Y] + texsize[Y])
		vertex_add(0, 0, rad, 0, 0, 1, tex1[X] + texsize[X] * i, tex1[Y])
		vertex_add(x1, y1, -rad, n1x, n1y, 0, tex1[X] + texsize[X] * ip, tex1[Y] + texsize[Y])
	}
	else
	{
		vertex_add(0, 0, rad, 0, 0, 1, tex1[X] + texsize[X] * i, tex1[Y])
		vertex_add(x2, y2, -rad, n2x, n2y, 0, tex1[X] + texsize[X] * i, tex1[Y] + texsize[Y])
		vertex_add(x1, y1, -rad, n1x, n1y, 0, tex1[X] + texsize[X] * ip, tex1[Y] + texsize[Y])
	}
}

return vbuffer_done()
