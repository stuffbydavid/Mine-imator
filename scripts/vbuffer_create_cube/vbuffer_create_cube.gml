/// vbuffer_create_cube(radius, tex1, tex2, texhorflip, texverflip, invert, mapped)
/// @arg radius
/// @arg tex1
/// @arg tex2
/// @arg texhorflip
/// @arg texverflip
/// @arg invert
/// @arg mapped

var rad, tex1, tex2, thflip, tvflip, invert, mapped;
rad = argument0
tex1 = argument1
tex2 = argument2
thflip = argument3
tvflip = argument4
invert = argument5
mapped = argument6

vbuffer_start()

var texsize = point2D(1 / 3, 1 / 2);

// X+
if (mapped)
{
    if (invert)
        tex1[X] = texsize[X]
    else
        tex1[X] = texsize[X] * 2
		
    tex1[Y] = 0
	tex2 = point2D_add(tex1, texsize)
	
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
    vbuffer_add_triangle(rad, rad, rad, rad, rad, -rad, rad, -rad, rad, tex1[X], tex1[Y], tex1[X], tex2[Y], tex2[X], tex1[Y])
    vbuffer_add_triangle(rad, -rad, rad, rad, rad, -rad, rad, -rad, -rad, tex2[X], tex1[Y], tex1[X], tex2[Y], tex2[X], tex2[Y])
}
else
{
    vbuffer_add_triangle(rad, rad, -rad, rad, rad, rad, rad, -rad, rad, tex1[X], tex2[Y], tex1[X], tex1[Y], tex2[X], tex1[Y])
    vbuffer_add_triangle(rad, rad, -rad, rad, -rad, rad, rad, -rad, -rad, tex1[X], tex2[Y], tex2[X], tex1[Y], tex2[X], tex2[Y])
}

// X-
if (mapped)
{
    if (invert)
        tex1[X] = texsize[X] * 2
    else
        tex1[X] = texsize[X]
		
    tex1[Y] = 0
	tex2 = point2D_add(tex1, texsize)
	
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
    vbuffer_add_triangle(-rad, rad, -rad, -rad, rad, rad, -rad, -rad, rad, tex2[X], tex2[Y], tex2[X], tex1[Y], tex1[X], tex1[Y])
    vbuffer_add_triangle(-rad, rad, -rad, -rad, -rad, rad, -rad, -rad, -rad, tex2[X], tex2[Y], tex1[X], tex1[Y], tex1[X], tex2[Y])
}
else
{
    vbuffer_add_triangle(-rad, rad, rad, -rad, rad, -rad, -rad, -rad, rad, tex2[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex1[Y])
    vbuffer_add_triangle(-rad, -rad, rad, -rad, rad, -rad, -rad, -rad, -rad, tex1[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex2[Y])
}

// Y+
if (mapped)
{
	tex1 = point2D(0, 0)
	tex2 = point2D_add(tex1, texsize)
	
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
    vbuffer_add_triangle(rad, rad, rad, -rad, rad, rad, rad, rad, -rad, tex2[X], tex1[Y], tex1[X], tex1[Y], tex2[X], tex2[Y])
    vbuffer_add_triangle(-rad, rad, rad, -rad, rad, -rad, rad, rad, -rad, tex1[X], tex1[Y], tex1[X], tex2[Y], tex2[X], tex2[Y])
}
else
{
    vbuffer_add_triangle(-rad, rad, rad, rad, rad, rad, rad, rad, -rad, tex1[X], tex1[Y], tex2[X], tex1[Y], tex2[X], tex2[Y])
    vbuffer_add_triangle(-rad, rad, -rad, -rad, rad, rad, rad, rad, -rad, tex1[X], tex2[Y], tex1[X], tex1[Y], tex2[X], tex2[Y])
}

// Y-
if (mapped)
{
	tex1 = point2D(0, texsize[Y])
	tex2 = point2D_add(tex1, texsize)
	
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
    vbuffer_add_triangle(-rad, -rad, rad, rad, -rad, rad, rad, -rad, -rad, tex2[X], tex1[Y], tex1[X], tex1[Y], tex1[X], tex2[Y])
    vbuffer_add_triangle(-rad, -rad, -rad, -rad, -rad, rad, rad, -rad, -rad, tex2[X], tex2[Y], tex2[X], tex1[Y], tex1[X], tex2[Y])
}
else
{
    vbuffer_add_triangle(rad, -rad, rad, -rad, -rad, rad, rad, -rad, -rad, tex1[X], tex1[Y], tex2[X], tex1[Y], tex1[X], tex2[Y])
    vbuffer_add_triangle(-rad, -rad, rad, -rad, -rad, -rad, rad, -rad, -rad, tex2[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex2[Y])
}

// Z+
if (mapped)
{
	tex1 = texsize
	tex2 = point2D_add(tex1, texsize)
	
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
    vbuffer_add_triangle(rad, -rad, rad, -rad, -rad, rad, -rad, rad, rad, tex2[X], tex1[Y], tex1[X], tex1[Y], tex1[X], tex2[Y])
    vbuffer_add_triangle(rad, rad, rad, rad, -rad, rad, -rad, rad, rad, tex2[X], tex2[Y], tex2[X], tex1[Y], tex1[X], tex2[Y])
}
else
{
    vbuffer_add_triangle(-rad, -rad, rad, rad, -rad, rad, -rad, rad, rad, tex1[X], tex1[Y], tex2[X], tex1[Y], tex1[X], tex2[Y])
    vbuffer_add_triangle(rad, -rad, rad, rad, rad, rad, -rad, rad, rad, tex2[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex2[Y])
}

// Z-
if (mapped)
{
	tex1 = vec2_mul(texsize, 2)
	tex2 = point2D_add(tex1, texsize)
	
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
    vbuffer_add_triangle(-rad, -rad, -rad, rad, -rad, -rad, -rad, rad, -rad, tex1[X], tex2[Y], tex2[X], tex2[Y], tex1[X], tex1[Y])
    vbuffer_add_triangle(rad, -rad, -rad, rad, rad, -rad, -rad, rad, -rad, tex2[X], tex2[Y], tex2[X], tex1[Y], tex1[X], tex1[Y])
}
else
{
    vbuffer_add_triangle(rad, -rad, -rad, -rad, -rad, -rad, -rad, rad, -rad, tex2[X], tex2[Y], tex1[X], tex2[Y], tex1[X], tex1[Y])
    vbuffer_add_triangle(rad, rad, -rad, rad, -rad, -rad, -rad, rad, -rad, tex2[X], tex1[Y], tex2[X], tex2[Y], tex1[X], tex1[Y])
}

return vbuffer_done()
