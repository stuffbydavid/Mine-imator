/// temp_update_shape()

if (shape_vbuffer)
    vbuffer_destroy(shape_vbuffer)

var rad, thflip, tvflip, tex1, tex2;
rad = 8

// Set texture
thflip = test(shape_tex_hmirror, -1, 1)
tvflip = test(shape_tex_vmirror, -1, 1)
if (shape_invert)
    thflip *= -1

tex1 = point2D(shape_tex_hoffset, shape_tex_voffset)
tex2 = point2D(shape_tex_hoffset + shape_tex_hrepeat, shape_tex_voffset + shape_tex_vrepeat)

if (thflip < 0)
{
    tex1[X] = 1.0 - tex1[X]
    tex2[X] = 1.0 - tex2[X]
}
if (tvflip < 0)
{
    tex1[Y] = 1.0 - tex1[Y]
    tex2[Y] = 1.0 - tex2[Y]
}

switch (type)
{
    case "surface":
        shape_vbuffer = vbuffer_create_surface(rad, tex1, tex2, shape_invert)
        break
        
    case "cube":
        shape_vbuffer = vbuffer_create_cube(rad, tex1, tex2, thflip, tvflip, shape_invert, shape_tex_mapped)
        break
    
    case "cone":
        shape_vbuffer = vbuffer_create_cone(rad, tex1, tex2, thflip, tvflip, shape_detail, shape_closed, shape_invert, shape_tex_mapped)
        break
        
    case "cylinder":
        shape_vbuffer = vbuffer_create_cylinder(rad, tex1, tex2, thflip, tvflip, shape_detail, shape_closed, shape_invert, shape_tex_mapped)
        break
        
    case "sphere":
        shape_vbuffer = vbuffer_create_sphere(rad, tex1, tex2, shape_detail, shape_invert)
        break
}
