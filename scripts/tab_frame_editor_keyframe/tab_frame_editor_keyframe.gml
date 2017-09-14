/// tab_frame_editor_keyframe()

// Transition
var text = text_get("transition" + tl_edit.value[e_value.TRANSITION]);
tab_control(40)
draw_button_menu("frameeditortransition", e_menu.TRANSITION_LIST, dx, dy, dw, 40, tl_edit.value[e_value.TRANSITION], text, action_tl_frame_transition, transition_texture_small_map[?tl_edit.value[e_value.TRANSITION]])
tab_next()

// Visible
tab_control_checkbox()
draw_checkbox("frameeditorvisible", dx, dy, tl_edit.value[e_value.VISIBLE], action_tl_frame_visible)
tab_next()
