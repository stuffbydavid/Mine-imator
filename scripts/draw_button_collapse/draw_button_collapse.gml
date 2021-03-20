/// draw_button_collapse(name, value, script, disabled)
/// @arg name
/// @arg value
/// @arg script
/// @arg disabled

var val = draw_button_icon(argument0 + "collapse", dx - 8, dy + (tab_control_h / 2) - 8, 16, 16, argument1, null, argument2, argument3, (argument1 ? "tooltiphideoptions" : "tooltipshowoptions"), spr_chevron_ani)

dx += 12
dw -= 12
tab_collapse = true

return val;