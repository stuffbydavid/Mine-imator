/// background_sky_update()

if (!background_fog_color_custom) // Fog color
{
    background_fog_color_final = background_sky_color
    if (!background_image_show)
	{
        var cam_xyangle, p;
        cam_xyangle = point_direction(cam_from[X], cam_from[Y], cam_to[X], cam_to[Y]) - background_sky_rotation
        
        background_fog_color_final = merge_color(background_fog_color_final, merge_color(background_fog_color_final, 0, 0.95), background_night_alpha)
        background_fog_color_final = merge_color(background_fog_color_final, c_white, (1 - background_night_alpha) * 0.3)
        background_fog_color_final = merge_color(background_fog_color_final, merge_color(c_blue, c_black, 0.3), background_night_alpha * 0.05)
        
        // Sunset
        p = clamp(0, 1 - abs(angle_difference_fix(cam_xyangle, 90)) / 160, 1) * 0.75
        background_fog_color_final = merge_color(background_fog_color_final, c_orange, background_sunset_alpha * p)
        
        // Sunrise
        p = clamp(0, 1 - abs(angle_difference_fix(cam_xyangle, 270)) / 160, 1) * 0.75
        background_fog_color_final = merge_color(background_fog_color_final, c_orange, background_sunrise_alpha * p)
    }
}
