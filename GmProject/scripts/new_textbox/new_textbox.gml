/// @desc Creates a new textbox and sets its parameters.

function new_textbox(singleline, maxchars, filterchars)
{
	with (new_obj(obj_textbox))
	{
		text = ""					// Text in the textbox
		single_line = singleline	// If true, the textbox is limited to one line
		read_only = 0				// If true, the textbox contents cannot be changed in any way
		max_chars = maxchars		// If larger than 0, sets the maximum allowed number of characters
		filter_chars = filterchars	// If not "", these are the only allowed characters, "0123456789" to only allow digits
		replace_char = ""			// If not "", replaces all characters with this (text variable remains unchanged)
		select_on_focus = 1			// If true, all text will be selected upon focusing the textbox
		color_selected = -1			// The color of selected text, -1 for default
		color_selection = -1		// The color of the selection box, -1 for default
		suffix = ""
	
		start = 0					// Set the start line (multi-line) or start character (single-line)
		lines = 1					// Access the amount of lines in the textbox (read only)
		line[0] = ""				// Access a specific line from the textbox (read only)
	
		line_wrap[0] = 0
		line_single[0] = 0
		chars = 0
		last_text = ""
		last_width = 0
		jumpto = false
	
		return id
	}
}
