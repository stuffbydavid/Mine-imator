/// render_select(selectsurface)
/// @arg selectsurface

// Draw selection on separate surface
var hlsurf = surface_require(argument0, render_width, render_height);

surface_set_target(hlsurf)
{
    draw_clear_alpha(c_black, 0)
    
    render_world_start()
    render_world("select")
    render_world_done()
}
surface_reset_target()

// Draw border
if (surface_exists(render_target))
{
    surface_set_target(render_target)
	{
        gpu_set_texrepeat(false)
        
        shader_border_set(render_width, render_height)
        draw_surface_exists(hlsurf, 0, 0)
        shader_reset()
        
        gpu_set_texrepeat(true)
    }
    surface_reset_target()
}

return hlsurf
