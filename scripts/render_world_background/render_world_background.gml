/// render_world_background()
/// @desc Draws background color/image.

if (!render_background)
    return 0
    
draw_clear(background_sky_color)
if (background_image_show) // Draw image
{
    if (background_image && background_image_type = 0)
	{
        if (background_image_stretch)
            draw_texture(background_image.texture, 0, 0, render_width / texture_width(background_image.texture), render_height / texture_height(background_image.texture))
        else
            draw_texture(background_image.texture, 0, 0)
    }
}
else // Draw night
    draw_box(0, 0, render_width, render_height, false, c_black, background_sky_night_alpha() * 0.95)
