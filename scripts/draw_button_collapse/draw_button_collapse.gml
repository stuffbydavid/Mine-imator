/// draw_button_collapse(name, value, script, disabled)
/// @arg name
/// @arg value
/// @arg script
/// @arg disabled

draw_button_icon(argument0 + "collapse", dx, dy + (tab_control_h / 2) - 12 + 2, 20, 20, argument1, null, argument2, argument3, (argument1 ? "tooltiphideoptions" : "tooltipshowoptions"), spr_arrow_small_ani)

dx += 20 + 8
dw -= 20 + 8
tab_collapse = true