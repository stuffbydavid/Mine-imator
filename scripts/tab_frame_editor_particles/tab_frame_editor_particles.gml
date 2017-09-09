/// tab_frame_editor_particles()

var text, capwid;

// Spawn
tab_control_checkbox()
draw_checkbox("frameeditorspawn", dx, dy, tl_edit.value[e_value.SPAWN], action_tl_frame_spawn)
tab_next()

// Attractor
capwid = text_caption_width("frameeditorattractor", "frameeditorforce")
if (tl_edit.value[e_value.ATTRACTOR] != null)
	text = tl_edit.value[e_value.ATTRACTOR].display_name
else
	text = text_get("listnone")
	
tab_control(32)
draw_button_menu("frameeditorattractor", e_menu.TIMELINE, dx, dy, dw, 32, tl_edit.value[e_value.ATTRACTOR], text, action_tl_frame_attractor, null, null, capwid)
tab_next()

// Force
if (tl_edit.value[e_value.ATTRACTOR])
{
	tab_control_dragger()
	draw_dragger("frameeditorforce", dx, dy, dw, tl_edit.value[e_value.FORCE], 1 / 50, -no_limit, no_limit, 1, 0, tab.particles.tbx_force, action_tl_frame_force, capwid)
	tab_next()
}
