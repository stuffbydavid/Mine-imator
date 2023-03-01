/// textbox_startup()
/// @desc Creates variables for using textboxes.

function textbox_startup()
{
	textbox_lastfocus = -1
	textbox_click = false
	textbox_marker = 0
	textbox_mouseover = -1
	textbox_select_startline = 0
	textbox_select_startpos = 0
	textbox_select_endline = 0
	textbox_select_endpos = 0
	textbox_select_mouseline = 0
	textbox_select_mousepos = 0
	textbox_select_clickline = 0
	textbox_select_clickpos = 0
	textbox_isediting = false
	textbox_isediting_respond = false
	textbox_input = ""
	textbox_jump = false
	textbox_jumpto = -1
	textbox_list = ds_list_create()
}
