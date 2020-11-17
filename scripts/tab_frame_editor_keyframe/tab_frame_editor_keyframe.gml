/// tab_frame_editor_keyframe()

// Transition
var trans, text;
trans = tl_edit.value[e_value.TRANSITION]

if (trans != "linear" && trans != "instant")
{
	if (string_contains(trans, "easeinout"))
	{
		trans = string_replace(trans, "easeinout", "")
		text = text_get("transitioneaseinout", text_get("transitionease" + trans))
	}
	
	if (string_contains(trans, "easein"))
	{
		trans = string_replace(trans, "easein", "")
		text = text_get("transitioneasein", text_get("transitionease" + trans))
	}
	
	if (string_contains(trans, "easeout"))
	{
		trans = string_replace(trans, "easeout", "")
		text = text_get("transitioneaseout", text_get("transitionease" + trans))
	}
}
else
	text = text_get("transition" + trans)

tab_control_menu(44)
draw_button_menu("frameeditortransition", e_menu.TRANSITION_LIST, dx, dy, dw, 44, tl_edit.value[e_value.TRANSITION], text, action_tl_frame_transition, false, transition_texture_map[?tl_edit.value[e_value.TRANSITION]])
tab_next()

// Visible
tab_control_switch()
draw_switch("frameeditorvisible", dx, dy, tl_edit.value[e_value.VISIBLE], action_tl_frame_visible, true)
tab_next()
