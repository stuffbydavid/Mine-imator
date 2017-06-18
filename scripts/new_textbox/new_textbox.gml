/// new_textbox(singleline, maxchars, filterchars)
/// @arg singleline
/// @arg maxchars
/// @arg filterchars...
/// @desc Creates a new textbox and sets its parameters.

var tbx = new(obj_textbox);

// Feel free to change / use these variables after creating the object
tbx.text = ""					 // Text in the textbox
tbx.single_line = argument0	   // If true, the textbox is limited to one line
tbx.read_only = 0				 // If true, the textbox contents cannot be changed in any way
tbx.max_chars = argument1		 // If larger than 0, sets the maximum allowed number of characters
tbx.filter_chars = argument2	  // If not "", these are the only allowed characters, "0123456789" to only allow digits
tbx.replace_char = ""			 // If not "", replaces all characters with this (text variable remains unchanged)
tbx.select_on_focus = 1		   // If true, all text will be selected upon focusing the textbox
tbx.color_selected = -1		   // The color of selected text, -1 for default
tbx.color_selection = -1		  // The color of the selection box, -1 for default
tbx.suffix = ""
tbx.next_tbx = null

tbx.start = 0			   // Set the start line (multi - line) or start character (single - line)
tbx.lines = 1			   // Access the amount of lines in the textbox (read only)
tbx.line[0] = ""			// Access a specific line from the textbox (read only)

// Don't touch
tbx.line_wrap[0] = 0
tbx.line_single[0] = 0
tbx.chars = 0
tbx.last_text = ""
tbx.last_width = 0

return tbx
