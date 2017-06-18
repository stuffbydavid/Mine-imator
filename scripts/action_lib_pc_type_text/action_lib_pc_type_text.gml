/// action_lib_pc_type_text(text)
/// @arg text

var text;

if (history_undo)
	text = history_data.oldval
else if (history_redo)
	text = history_data.newval
else
{
	text = argument0
	history_set_var(action_lib_pc_type_text, ptype_edit.text, text, true)
}

ptype_edit.text = text
