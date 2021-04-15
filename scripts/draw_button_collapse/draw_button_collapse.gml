/// draw_button_collapse(name, [value, script, disabled])
/// @arg name
/// @arg [value
/// @arg script
/// @arg disabled]

var name, value, script, disabled;
name = argument[0]

if (argument_count > 1)
{
	value = argument[1]
	script = argument[2]
	disabled = argument[3]
}
else
{
	value = collapse_map[?name]
	script = null
	disabled = false
}

var val = draw_button_icon(name + "collapse", dx - 8, dy + (tab_control_h / 2) - 8, 16, 16, value && !disabled, null, script, disabled, (value ? "tooltiphideoptions" : "tooltipshowoptions"), spr_chevron_ani)

dx += 12
dw -= 12
tab_collapse = true
collapse_ani = mcroani_arr[e_mcroani.ACTIVE]

// Interact with collapse map?
if (val && ds_map_exists(collapse_map, name))
	action_collapse(name, !collapse_map[?name])

return val;