/// res_load_skin(filename/texture)
/// @arg filename/texture
/// @desc Adds a human skin from the given filename or texture.

var fn, tex, tw, th, size, scale, surf, needconvert, newtex;
fn = argument0
needconvert = true // Need 1.8 convert

if (is_string(fn))
    tex = texture_create(fn)
else
    tex = fn

tw = texture_width(tex)
th = texture_height(tex)
size = max(tw, th)
scale = size / 64

surf = surface_create(size, size)
surface_set_target(surf)
{
    draw_clear_alpha(c_black, 0)
    draw_texture(tex, 0, 0)
}
surface_reset_target()

buffer_current = buffer_create(size * size * 4, buffer_fixed, 4)
buffer_get_surface(buffer_current, surf, 0, 0, 0)

if (tw = th) // Square, possibly a 1.8 skin, check for pixels
{
    for (var xx = 0; xx < size; xx++)
	{
        for (var yy = size - 1; yy >= size / 2; yy--)
		{
            if (buffer_read_alpha(xx, yy, size) > 0) // A pixel was found below y = 32, this is a 1.8 skin
			{
                needconvert = false
                break
            }
        }
        if (!needconvert)
            break
    }
}

buffer_delete(buffer_current)

if (needconvert)
{
    render_set_culling(false)
    surface_set_target(surf)
	{
        // Leg
        draw_texture_part(tex, 28 * scale, 52 * scale, 0 * scale, 20 * scale, 4 * scale, 12 * scale, -1, 1) // Side 1
        draw_texture_part(tex, 24 * scale, 52 * scale, 4 * scale, 20 * scale, 4 * scale, 12 * scale, -1, 1) // Front
        draw_texture_part(tex, 20 * scale, 52 * scale, 8 * scale, 20 * scale, 4 * scale, 12 * scale, -1, 1) // Side 2
        draw_texture_part(tex, 32 * scale, 52 * scale, 12 * scale, 20 * scale, 4 * scale, 12 * scale, -1, 1) // Back
        draw_texture_part(tex, 24 * scale, 48 * scale, 4 * scale, 16 * scale, 4 * scale, 4 * scale, -1, 1) // Top
        draw_texture_part(tex, 28 * scale, 48 * scale, 8 * scale, 16 * scale, 4 * scale, 4 * scale, -1, 1) // Bottom
		
        // Arm
        draw_texture_part(tex, 44 * scale, 52 * scale, 40 * scale, 20 * scale, 4 * scale, 12 * scale, -1, 1) // Side 1
        draw_texture_part(tex, 40 * scale, 52 * scale, 44 * scale, 20 * scale, 4 * scale, 12 * scale, -1, 1) // Front
        draw_texture_part(tex, 36 * scale, 52 * scale, 48 * scale, 20 * scale, 4 * scale, 12 * scale, -1, 1) // Side 2
        draw_texture_part(tex, 48 * scale, 52 * scale, 52 * scale, 20 * scale, 4 * scale, 12 * scale, -1, 1) // Back
        draw_texture_part(tex, 40 * scale, 48 * scale, 44 * scale, 16 * scale, 4 * scale, 4 * scale, -1, 1) // Top
        draw_texture_part(tex, 44 * scale, 48 * scale, 48 * scale, 16 * scale, 4 * scale, 4 * scale, -1, 1) // Bottom
    }
    surface_reset_target()
    render_set_culling(true)
}

newtex = texture_surface(surf)

surface_free(surf)
texture_free(tex)

return newtex
