/// tab_frame_editor_particles()

function tab_frame_editor_particles()
{
	var text;
	
	// Spawn
	tab_control_checkbox()
	draw_switch("frameeditorparticlesspawn", dx, dy, tl_edit.value[e_value.SPAWN], action_tl_frame_spawn)
	tab_next()
	
	// Advanced mode only
	if (setting_advanced_mode)
	{
		// Freeze
		tab_control_checkbox()
		draw_switch("frameeditorparticlesfreeze", dx, dy, tl_edit.value[e_value.FREEZE], action_tl_frame_freeze)
		tab_next()
		
		// Clear
		tab_control_checkbox()
		draw_switch("frameeditorparticlesclear", dx, dy, tl_edit.value[e_value.CLEAR], action_tl_frame_clear)
		tab_next()
		
		// Custom seed
		tab_control_checkbox()
		draw_switch("frameeditorparticlescustomseed", dx, dy, tl_edit.value[e_value.CUSTOM_SEED], action_tl_frame_custom_seed)
		tab_next()
		
		if (tl_edit.value[e_value.CUSTOM_SEED])
		{
			// Seed
			tab_control_dragger()
			draw_dragger("frameeditorparticlesseed", dx, dy, dragger_width, tl_edit.value[e_value.SEED], 0.1, 0, 32000, 0, 1, tab.particles.tbx_seed, action_tl_frame_seed)
			tab_next()
		}
	}
	
	// Attractor
	if (tl_edit.value[e_value.ATTRACTOR] != null)
		text = tl_edit.value[e_value.ATTRACTOR].display_name
	else
		text = text_get("listnone")
	
	tab_control_menu()
	draw_button_menu("frameeditorparticlesattractor", e_menu.TIMELINE, dx, dy, dw, 24, tl_edit.value[e_value.ATTRACTOR], text, action_tl_frame_attractor)
	tab_next()
	
	// Force
	if (tl_edit.value[e_value.ATTRACTOR])
	{
		tab_control_dragger()
		draw_dragger("frameeditorparticlesforce", dx, dy, dragger_width, tl_edit.value[e_value.FORCE], 0.02, -no_limit, no_limit, 1, 0, tab.particles.tbx_force, action_tl_frame_force)
		tab_next()
		
		if (tl_edit.value[e_value.ATTRACTOR].type = e_tl_type.PATH)
		{
			tab_control_dragger()
			draw_dragger("frameeditorparticlesforcedirectional", dx, dy, dragger_width, tl_edit.value[e_value.FORCE_DIRECTIONAL], 0.02, -no_limit, no_limit, 1, 0, tab.particles.tbx_force_directional, action_tl_frame_force_directional)
			tab_next()
			
			tab_control_dragger()
			draw_dragger("frameeditorparticlesforcevortex", dx, dy, dragger_width, tl_edit.value[e_value.FORCE_VORTEX], 0.02, -no_limit, no_limit, 1, 0, tab.particles.tbx_force_vortex, action_tl_frame_force_vortex)
			tab_next()
		}
	}
}
