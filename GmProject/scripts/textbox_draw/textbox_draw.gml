/// textbox_draw(textbox, x, y, width, height, [contextmenu, [right]])
/// @arg textbox
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [contextmenu
/// @arg [right]]
/// @desc Draws a box with editable text at the given position and with the given dimensions.

function textbox_draw(tbx, xx, yy, w, h, contextmenu = true, right = false)
{
	var changetext, deletetext, inserttext, lineheight, mouseover;
	var a, b, c, l, p, k, ww, hh, str, textx;
	
	// Colors
	var prevalpha, textnormal, textnormala, textsuffix, textsuffixa, highlight, texthighlight, texthighlighta;
	prevalpha = draw_get_alpha()
	textnormal = c_text_main
	textnormala = a_text_main * prevalpha
	textsuffix = c_text_tertiary
	textsuffixa = a_text_tertiary
	highlight = c_accent
	texthighlight = c_button_text
	texthighlighta = a_button_text * prevalpha
	
	if (tbx.last_text != tbx.text)
	{
		str = tbx.text
		str = string_replace_all(str, "\r\n", "\n")
		
		if (tbx.max_chars > 0)
			str = string_copy(str, 1, tbx.max_chars)
		
		if (tbx.single_line)
			str = string_replace_all(str, "\n", " ")
		tbx.text = str
		
		str += "\n"
		tbx.lines = 0
		while (str != "")
		{
			tbx.line[tbx.lines] = string_copy(str, 1, string_pos("\n", str) - 1)
			tbx.line_wrap[tbx.lines] = 0
			tbx.line_single[tbx.lines] = 0
			tbx.lines++
			str = string_delete(str, 1, string_pos("\n", str))
		}
		changetext = true
	}
	else
		changetext = false
	
	deletetext = 0
	inserttext = ""
	lineheight = string_height(" ")
	mouseover = (content_mouseon && app_mouse_box(xx, yy, w, h))
	
	if (!mouse_left && ((window_busy = string(tbx) + "tbxrelease") || (window_busy = string(tbx) + "click")))
		window_busy = ""
	
	if (window_focus = string(tbx))
	{
		if (contextmenu)
			context_menu_area(xx, yy, w, h, "contextmenutextbox", tbx, e_context_type.NONE, null, null)
		
		var keys, key_press, action;
		textbox_isediting = true
		textbox_isediting_respond = true
		
		if (textbox_lastfocus != tbx) // Select all
		{
			textbox_select_endline = tbx.lines - 1
			textbox_select_endpos = string_length(tbx.line[textbox_select_endline])
			
			if (tbx.select_on_focus)
			{
				textbox_select_startline = 0
				textbox_select_startpos = 0
			}
			else
			{
				textbox_select_startline = textbox_select_endline
				textbox_select_startpos = textbox_select_endpos
			}
			
			textbox_select_mouseline = textbox_select_endline
			textbox_select_mousepos = textbox_select_endpos
			textbox_select_clickline = 0 
			textbox_select_clickpos = 0
		}
		
		// Automatic key presses
		keys = array(
			vk_enter,
			vk_backspace,
			vk_delete,
			ord("V"),
			vk_right,
			vk_left,
			vk_up,
			vk_down
		)
		
		for (k = 0; k < array_length(keys); k++)
		{
			key_press[keys[k]] = false
			if (keyboard_check(keys[k]))
			{
				if (current_time - textbox_key_delay[k] > 30)
				{
					key_press[keys[k]] = true
					textbox_key_delay[k] = current_time + 500 * keyboard_check_pressed(keys[k]) // 500 msec if first press, otherwise 30
				}
			}
			else
				textbox_key_delay[k] = 0
		}
		
		if (!mouseover && (mouse_left_pressed && !keyboard_check(vk_shift) && !context_menu_mouseon) || (tbx.single_line && keyboard_check_pressed(vk_enter)))
			window_focus = ""
		
		if (!tbx.read_only && window_busy = "" && !keyboard_check(vk_control))
		{
			// 0 = Do nothing, 1 = Erase to left, -1 = Erase to right, 2 = Delete selected
			deletetext = key_press[vk_backspace] - key_press[vk_delete]
			inserttext = textbox_input
		}
		
		// Controls
		if (!tbx.single_line)
		{
			tbx.start += mouse_wheel_down() - mouse_wheel_up() // Mouse wheel to scroll
			if (key_press[vk_enter] && !tbx.read_only) // Enter for linebreak
				inserttext = "\n"
		}
		
		if (key_press[vk_right] || key_press[vk_left] ||
			(key_press[vk_up] && textbox_select_mouseline > 0) ||
			(key_press[vk_down] && textbox_select_mouseline < tbx.lines - 1)) // Arrow keys to move marker
		{
			if (key_press[vk_right] || key_press[vk_left])
			{
				// Move marker around words
				if (keyboard_check(vk_control))
				{
					if (key_press[vk_right])
					{
						var char = string_char_at(tbx.text, textbox_select_mousepos + 1);
						
						if (char = " " || char = "\n")
						{
							textbox_select_mousepos++
							char = string_char_at(tbx.text, textbox_select_mousepos + 1)
						}
						
						while (true)
						{
							char = string_char_at(tbx.text, textbox_select_mousepos + 1)
							
							if (char = "" || char = " " || char = "\n")
								break
							
							// End of textbox
							if (textbox_select_mouseline = tbx.lines - 1 && textbox_select_mousepos >= string_length(tbx.line[textbox_select_mouseline]))
							{
								textbox_select_mousepos = string_length(tbx.line[textbox_select_mouseline])
								break
							}
							
							textbox_select_mousepos++
							
							// Skip lines
							while (textbox_select_mousepos > string_length(tbx.line[textbox_select_mouseline]))
							{
								textbox_select_mouseline++
								textbox_select_mousepos = 0
							}
						}
					}
					else
					{
						var char = string_char_at(tbx.text, textbox_select_mousepos);
						
						if (char = " " || char = "\n" || textbox_select_mousepos = 0)
						{
							textbox_select_mousepos--
							char = string_char_at(tbx.text, textbox_select_mousepos)
						}
						
						while (true)
						{
							char = string_char_at(tbx.text, textbox_select_mousepos)
							
							if (char = "" || char = " " || char = "\n" || (tbx.line[textbox_select_mouseline] != "" && textbox_select_mousepos = 0))
								break
							
							// End of textbox
							if (textbox_select_mouseline = 0 && textbox_select_mousepos <= 0)
							{
								textbox_select_mousepos = 0
								break
							}
							
							textbox_select_mousepos--
							
							// Skip lines
							while (textbox_select_mousepos < 0)
							{
								textbox_select_mouseline--
								textbox_select_mousepos = string_length(tbx.line[textbox_select_mouseline])
							}
						}
					}
				}
				else
				{
					textbox_select_mousepos += (key_press[vk_right] - key_press[vk_left]) // Move marker right or left
					
					if (textbox_select_mousepos > string_length(tbx.line[textbox_select_mouseline])) // Check if beyond end of line
					{
						if (textbox_select_mouseline < tbx.lines - 1) // Wrap around to next line
						{
							textbox_select_mouseline++
							textbox_select_mousepos = 0
						}
						else
							textbox_select_mousepos--
					}
					if (textbox_select_mousepos < 0) // Check if before start of line
					{
						if (textbox_select_mouseline > 0)
						{
							textbox_select_mouseline--
							textbox_select_mousepos = string_length(tbx.line[textbox_select_mouseline])
						}
						else
							textbox_select_mousepos++
					}
				}
			}
			
			if (!tbx.single_line && (key_press[vk_up] || key_press[vk_down])) // Move marker up / down
			{
				var currentx, nextx;
				currentx = string_width(string_copy(tbx.line[textbox_select_mouseline], 1, textbox_select_mousepos))
				nextx = 0
				textbox_select_mouseline += key_press[vk_down] - key_press[vk_up]
				
				for (textbox_select_mousepos = 0;
					 textbox_select_mousepos <= string_length(tbx.line[textbox_select_mouseline]);
					 textbox_select_mousepos++) // Find correct position
				{
					nextx += string_width(string_char_at(tbx.line[textbox_select_mouseline], textbox_select_mousepos))
					if (nextx > currentx)
						break
				}
			}
			
			if (!keyboard_check(vk_shift))
			{
				textbox_select_clickline = textbox_select_mouseline
				textbox_select_clickpos = textbox_select_mousepos
			}
			
			textbox_select_startline = textbox_select_mouseline
			textbox_select_startpos = textbox_select_mousepos
			textbox_select_endline = textbox_select_mouseline
			textbox_select_endpos = textbox_select_mousepos
			textbox_marker = current_time
		}
		
		action = -1
		if ((keyboard_check(vk_control) && window_busy = "") || context_menu_tbx_action) // Ctrl commands
		{
			if ((!tbx.read_only && keyboard_check_pressed(ord("X"))) || context_menu_tbx_cut)
				action = 0
			
			if (keyboard_check_pressed(ord("C")) || context_menu_tbx_copy)
				action = 1
			
			if ((!tbx.read_only && key_press[ord("V")]) || context_menu_tbx_paste)
				action = 2
			
			if (keyboard_check_pressed(ord("A")) || context_menu_tbx_select_all)
				action = 4
			
			context_menu_tbx_action = false
			context_menu_tbx_cut = false
			context_menu_tbx_copy = false
			context_menu_tbx_paste = false
			context_menu_tbx_select_all = false
		}
		
		switch (action)
		{
			case 0:
			case 1: // Cut/Copy text
			{ 
				str = ""
				if (textbox_select_startline = textbox_select_endline) // Get text on single line
					str = string_copy(tbx.line[textbox_select_startline], textbox_select_startpos + 1, textbox_select_endpos - textbox_select_startpos)
				else
				{
					for (l = textbox_select_startline; l <= textbox_select_endline; l++) // Get selected text
					{
						if (l = textbox_select_startline)
							str += string_delete(tbx.line[l], 1, textbox_select_startpos)
						else if (l = textbox_select_endline)
							str += string_copy(tbx.line[l], 1, textbox_select_endpos)
						else
							str += tbx.line[l]
						
						if (l < textbox_select_endline)
							if (!tbx.line_wrap[l + 1] && !tbx.line_single[l])
								str += "\r\n"
					}
				}
				
				if (str != "")
					clipboard_set_text(str)
				
				if (action = 0)
					deletetext = 2
				
				break
			}
			
			case 2: // Paste text
			{
				inserttext = string(clipboard_get_text())
				inserttext = string_replace_all(inserttext, "\r\n", "\n")
				break
			}
			
			case 3: // Delete text
			{
				deletetext = 2
				break
			}
			
			case 4: // Select all text
			{
				textbox_select_startline = 0
				textbox_select_startpos = 0
				textbox_select_endline = tbx.lines - 1
				textbox_select_endpos = string_length(tbx.line[textbox_select_endline])
				textbox_select_mouseline = textbox_select_endline
				textbox_select_mousepos = textbox_select_endpos
				textbox_select_clickline = 0
				textbox_select_clickpos = 0
				break
			}
		}
		
		// Home/end controls
		var line = textbox_select_mouseline;
		
		if (keyboard_check_pressed(vk_home))
		{
			if (keyboard_check(vk_control))
				line = 0
			
			textbox_select_startline = line
			textbox_select_startpos = 0
			textbox_select_endline = line
			textbox_select_endpos = 0
			textbox_select_mouseline = line
			textbox_select_mousepos = 0
			textbox_select_clickline = line
			textbox_select_clickpos = 0
		}
		else if (keyboard_check_pressed(vk_end))
		{
			if (keyboard_check(vk_control))
				line = tbx.lines - 1
			
			line = line
			textbox_select_startpos = string_length(tbx.line[textbox_select_endline])
			textbox_select_endline = line
			textbox_select_endpos = textbox_select_startpos
			textbox_select_mouseline = line
			textbox_select_mousepos = textbox_select_startpos
			textbox_select_clickline = line
			textbox_select_clickpos = textbox_select_startpos
		}
		
		// Filter
		if (tbx.filter_chars != "" && inserttext != "")
		{
			str = ""
			for (p = 1; p <= string_length(inserttext); p++)
			{
				c = string_char_at(inserttext, p)
				str += string_repeat(c, string_pos(c, tbx.filter_chars) > 0)
			}
			inserttext = str
		}
		
		// Delete
		if (deletetext != 0 || inserttext != "")
		{
			if (textbox_select_startline != textbox_select_endline || textbox_select_startpos != textbox_select_endpos) // Several characters
			{
				if (textbox_select_startline = textbox_select_endline) // Same line, just do string_delete
					tbx.line[textbox_select_startline] = string_delete(tbx.line[textbox_select_startline], textbox_select_startpos + 1, textbox_select_endpos - textbox_select_startpos)
				else
				{
					// Delete all lines between the two points
					var linestodelete = textbox_select_endline - textbox_select_startline;
					tbx.line[textbox_select_startline] = string_copy(tbx.line[textbox_select_startline], 1, textbox_select_startpos) + string_delete(tbx.line[textbox_select_endline], 1, textbox_select_endpos)
					tbx.lines -= linestodelete
					
					for (l = textbox_select_startline + 1; l < tbx.lines; l++)
					{
						tbx.line[l] = tbx.line[l + linestodelete]
						tbx.line_wrap[l] = tbx.line_wrap[l + linestodelete]
						tbx.line_single[l] = tbx.line_single[l + linestodelete]
					}
				}
			}
			else if (deletetext < 2) // Single character
			{
				if (deletetext = 1) // Delete to the left (Backspace)
				{
					if (textbox_select_startpos > 0) // In middle of line, just do string_delete
					{ 
						tbx.line[textbox_select_startline] = string_delete(tbx.line[textbox_select_startline], textbox_select_startpos, 1)
						textbox_select_startpos--
					}
					else if (textbox_select_startline > 0) // Else, move up
					{
						textbox_select_startline--
						textbox_select_startpos = string_length(tbx.line[textbox_select_startline])
						
						if (tbx.line_wrap[textbox_select_startline + 1]) // If wrapped, delete, otherwise just jump up
						{
							textbox_select_startpos--
							tbx.line[textbox_select_startline] = string_copy(tbx.line[textbox_select_startline], 1, textbox_select_startpos)
						}
						
						tbx.line[textbox_select_startline] = tbx.line[textbox_select_startline] + tbx.line[textbox_select_startline + 1]
						tbx.lines--
						
						for (l = textbox_select_startline + 1; l < tbx.lines; l++)
						{
							tbx.line[l] = tbx.line[l + 1]
							tbx.line_wrap[l] = tbx.line_wrap[l + 1]
							tbx.line_single[l] = tbx.line_single[l + 1]
						}
					}
				}
				else if (deletetext = -1) // Delete to right (Delete)
				{
					if (textbox_select_startpos < string_length(tbx.line[textbox_select_startline]))
						tbx.line[textbox_select_startline] = string_delete(tbx.line[textbox_select_startline], textbox_select_startpos + 1, 1)
					else if (textbox_select_startline < tbx.lines - 1)
					{
						if (tbx.line_wrap[textbox_select_startline + 1]) // If wrapped, delete below
							tbx.line[textbox_select_startline + 1] = string_delete(tbx.line[textbox_select_startline + 1], 1, 1)
						else
						{
							tbx.line[textbox_select_startline] += tbx.line[textbox_select_startline + 1]
							tbx.lines--
						
							for (l = textbox_select_startline + 1; l < tbx.lines; l++)
							{
								tbx.line[l] = tbx.line[l + 1]
								tbx.line_wrap[l] = tbx.line_wrap[l + 1]
								tbx.line_single[l] = tbx.line_single[l + 1]
							}
						}
					}
				}
			}
			
			tbx.text = ""
			for (l = 0; l < tbx.lines; l++)
			{
				tbx.text += tbx.line[l]
				if (l < tbx.lines - 1 && !tbx.line_wrap[l + 1])
					tbx.text += "\n"
			}
			
			textbox_select_clickline = textbox_select_startline
			textbox_select_clickpos = textbox_select_startpos
			textbox_select_mouseline = textbox_select_startline
			textbox_select_mousepos = textbox_select_startpos
			textbox_select_endline = textbox_select_startline
			textbox_select_endpos = textbox_select_startpos
		}
		
		// Insert text
		if (tbx.max_chars > 0) // Check max limit
		{ 
			var maxlen = tbx.max_chars - string_length(tbx.text);
			if (string_length(inserttext) > maxlen)
				inserttext = string_copy(inserttext, 1, maxlen)
		}
		
		if (inserttext != "")
		{
			textbox_marker = current_time
			if (tbx.single_line)
				inserttext = string_replace_all(inserttext, "\n", " ")
			
			realmousepos = textbox_select_mousepos // Get real position in total string
			for (l = 0; l < textbox_select_mouseline; l++)
				realmousepos += string_length(tbx.line[l]) + (!tbx.line_wrap[l + 1] && !tbx.line_single[l])
			tbx.text = string_copy(tbx.text, 1, realmousepos) + inserttext + string_delete(tbx.text, 1, realmousepos)
			
			if (string_pos("\n", inserttext) > 0) // Add text with multiple lines (Paste or linebreak)
			{
				inserttext += "\n"
				a = tbx.line[textbox_select_mouseline]
				b = -1
				
				while (inserttext != "") // Parse
				{
					b++
					str[b] = string_copy(inserttext, 1, string_pos("\n", inserttext) - 1)
					if (tbx.replace_char != "")
						str[b] = string_repeat(tbx.replace_char, string_length(str[b]))
					inserttext = string_delete(inserttext, 1, string_pos("\n", inserttext))
				}
				tbx.lines += b
				
				for (l = tbx.lines - 1; l >= textbox_select_mouseline + b; l--) //Push up
				{
					tbx.line[l] = tbx.line[l - b]
					tbx.line_wrap[l] = tbx.line_wrap[l - b]
					tbx.line_single[l] = tbx.line_single[l - b]
				}
				
				for (l = 0; l <= b; l++) // Insert
				{
					if (l = 0)
					{
						tbx.line[textbox_select_mouseline + l] = string_copy(a, 1, textbox_select_mousepos) + str[l] // First
						tbx.line_single[textbox_select_mouseline + l] = false
					}
					else if (l = b)
					{
						tbx.line[textbox_select_mouseline + l] = str[l] + string_delete(a, 1, textbox_select_mousepos) // Last
						tbx.line_wrap[textbox_select_mouseline + l] = false
					}
					else
						tbx.line[textbox_select_mouseline + l] = str[l] // Middle
				}
				textbox_select_mouseline += b
				textbox_select_mousepos = string_length(str[b])
				inserttext = " "
			}
			else // Simple insert
			{
				if (tbx.replace_char != "")
					inserttext = string_repeat(tbx.replace_char, string_length(inserttext))
				
				// Apparently, string_insert doesn't support special ASCII
				tbx.line[textbox_select_startline] = string_copy(tbx.line[textbox_select_startline], 1, textbox_select_mousepos) + inserttext + string_delete(tbx.line[textbox_select_startline], 1, textbox_select_mousepos)
				textbox_select_mousepos += string_length(inserttext)
			}
			
			textbox_select_clickline = textbox_select_mouseline
			textbox_select_clickpos = textbox_select_mousepos
			textbox_select_startline = textbox_select_mouseline
			textbox_select_startpos = textbox_select_mousepos
			textbox_select_endline = textbox_select_mouseline
			textbox_select_endpos = textbox_select_mousepos
		}
		
		// Move screen if text is edited or marker is moved
		if (inserttext != "" || deletetext != 0 || key_press[vk_left] || key_press[vk_right] || key_press[vk_up] || key_press[vk_down])
		{
			if (tbx.single_line)
			{
				if (textbox_select_mousepos < tbx.start) // Move screen left
					tbx.start = textbox_select_mousepos 
				
				if (textbox_select_mousepos > tbx.start + tbx.chars - 1) // Move screen right
					tbx.start = textbox_select_mousepos - tbx.chars 
			}
			else
			{
				if (textbox_select_mouseline < tbx.start) // Move screen up
					tbx.start = textbox_select_mouseline
				
				if (textbox_select_mouseline >= tbx.start + floor(h / lineheight)) // Move screen down
					tbx.start = textbox_select_mouseline - floor(h / lineheight) + 1
			}
		}
		
		// Handle selecting
		if (!mouse_left && (window_busy = string(tbx) + "click"))
			window_busy = ""
		
		if (!mouse_left && (window_busy = string(tbx)))
			window_busy = string(tbx) + "tbxrelease"
		
		if (window_busy = string(tbx)) // Move up/down if dragging outside of box
		{
			textbox_marker = current_time
			if (tbx.single_line)
			{
				if (mouse_x < xx)
					tbx.start--
				
				if (mouse_x > xx + w)
					tbx.start++
			}
			else
			{
				if (mouse_y < yy)
					tbx.start--
				
				if (mouse_y > yy + h)
					tbx.start++
			}
		}
		
		if (textbox_click > 0)
		{
			if (textbox_select_mouseline = textbox_select_clickline)
			{
				textbox_select_startline = textbox_select_mouseline
				textbox_select_endline = textbox_select_mouseline
				
				if (textbox_select_mousepos >= textbox_select_clickpos)
				{
					textbox_select_startpos = textbox_select_clickpos
					textbox_select_endpos = textbox_select_mousepos
				}
				else
				{
					textbox_select_startpos = textbox_select_mousepos
					textbox_select_endpos = textbox_select_clickpos
				}
			}
			
			if (textbox_select_mouseline > textbox_select_clickline)
			{
				textbox_select_startline = textbox_select_clickline
				textbox_select_startpos = textbox_select_clickpos
				textbox_select_endline = textbox_select_mouseline
				textbox_select_endpos = textbox_select_mousepos
			}
			
			if (textbox_select_mouseline < textbox_select_clickline)
			{
				textbox_select_startline = textbox_select_mouseline
				textbox_select_startpos = textbox_select_mousepos
				textbox_select_endline = textbox_select_clickline
				textbox_select_endpos = textbox_select_clickpos
			}
		}
	}
	
	if (tbx.single_line) // Calculate the amount of characters visible
	{
		// Avoid negative start character
		tbx.start = max(0, tbx.start)
		
		// Find minimum position
		ww = 0
		for (a = string_length(tbx.line[0]); a >= 0; a--)
		{
			ww += string_width(string_char_at(tbx.line[0], a))
			b = a
			if (ww > w)
				break
		}
		
		tbx.start = min(b, tbx.start)
		
		// Calculate visible
		ww = 0
		tbx.chars = 0
		
		for (a = tbx.start + 1; a <= string_length(tbx.line[0]); a++)
		{
			ww += string_width(string_char_at(tbx.line[0], a))
			if (ww > w)
				break
			tbx.chars++
		}
	}
	else // Wordwrapping
	{
		if (changetext || tbx.last_width != w || inserttext != "" || deletetext != 0) // Detect box width or line length changes
		{
			for (l = 1; l < tbx.lines; l++) // Move words up?
			{
				ww = string_width(tbx.line[l - 1])
				if (!tbx.line_wrap[l] || ww > w)
					continue
				
				if (tbx.line_single[l - 1]) // Single-worded line
				{
					for (p = 1; p <= string_length(tbx.line[l]); p++) // Try to add remaining letters
					{
						if (ww + string_width(string_copy(tbx.line[l], 1, p)) > w)
							break
						
						a = string_char_at(tbx.line[l], p + 1)
						if (a = " " || a = "-")
						{
							p++
							tbx.line_single[l - 1] = false
							break
						}
						
						if (p = string_length(tbx.line[l]) && !tbx.line_single[l])
							tbx.line_single[l - 1] = false
					}
					
					if (p = 1) //Cannot move up
						continue
					
					// Move markers if affected
					a = string_length(tbx.line[l - 1])
					
					if (textbox_select_mouseline = l && textbox_select_mousepos <= p)
					{
						textbox_select_mouseline--
						textbox_select_mousepos += a
					}
					
					if (textbox_select_clickline = l && textbox_select_clickpos <= p)
					{
						textbox_select_clickline--
						textbox_select_clickpos += a
					}
					
					if (textbox_select_endline = l && textbox_select_endpos <= p)
					{
						textbox_select_endline--
						textbox_select_endpos += a
					}
					
					if (textbox_select_startline = l && textbox_select_startpos <= p)
					{
						textbox_select_startline--
						textbox_select_startpos += a
					}
					
					if (textbox_select_mouseline = l)
						textbox_select_mousepos -= p
					
					if (textbox_select_clickline = l)
						textbox_select_clickpos -= p
					
					if (textbox_select_endline = l)
						textbox_select_endpos -= p
					
					if (textbox_select_startline = l)
						textbox_select_startpos -= p
					
					tbx.line[l - 1] += string_copy(tbx.line[l], 1, p)
					tbx.line[l] = string_delete(tbx.line[l], 1, p)
				}
				
				while (tbx.line[l] != "") // Try to add words
				{
					p = string_pos(" ", tbx.line[l])
					
					if (p = 0)
						p = string_pos(" - ", tbx.line[l])
					
					if (p = 0)
						p = string_length(tbx.line[l])
					
					if (ww + string_width(string_copy(tbx.line[l], 1, p - 1)) > w)
						break
					
					// Move markers if affected
					a = string_length(tbx.line[l - 1])
					
					if (textbox_select_mouseline = l && textbox_select_mousepos <= p)
					{
						textbox_select_mouseline--
						textbox_select_mousepos += a
					}
					
					if (textbox_select_clickline = l && textbox_select_clickpos <= p)
					{
						textbox_select_clickline--
						textbox_select_clickpos += a
					}
					
					if (textbox_select_endline = l && textbox_select_endpos <= p)
					{
						textbox_select_endline--
						textbox_select_endpos += a
					}
					
					if (textbox_select_startline = l && textbox_select_startpos <= p)
					{
						textbox_select_startline--
						textbox_select_startpos += a
					}
					
					if (textbox_select_mouseline = l)
						textbox_select_mousepos -= p
					
					if (textbox_select_clickline = l)
						textbox_select_clickpos -= p
					
					if (textbox_select_endline = l)
						textbox_select_endpos -= p
					
					if (textbox_select_startline = l)
						textbox_select_startpos -= p
					
					tbx.line[l - 1] += string_copy(tbx.line[l], 1, p)
					tbx.line[l] = string_delete(tbx.line[l], 1, p)
				}
				
				if (tbx.line[l] = "") // Remove empty line
				{
					tbx.lines--
					for (a = l; a < tbx.lines; a++)
					{
						tbx.line[a] = tbx.line[a + 1]
						tbx.line_wrap[a] = tbx.line_wrap[a + 1]
						tbx.line_single[a] = tbx.line_single[a + 1]
						
						// Move markers if affected
						if (textbox_select_mouseline = a + 1)
							textbox_select_mouseline--
						if (textbox_select_clickline = a + 1)
							textbox_select_clickline--
						if (textbox_select_endline = a + 1)
							textbox_select_endline--
						if (textbox_select_startline = a + 1)
							textbox_select_startline--
					}
					l--
				}
			}
			
			for (l = 0; l < tbx.lines; l++) // Move words down?
			{
				if (string_width(tbx.line[l]) > w)
				{
					tbx.line_single[l] = false
					
					for (p = string_length(tbx.line[l]); p > 1; p--) // Look for words
					{
						a = string_char_at(tbx.line[l], p)
						if ((a = " " || a = "-") && string_width(string_copy(tbx.line[l], 1, p - 1)) < w)
							break
					}
					
					if (p = 1) // Single-word line found
					{
						tbx.line_single[l] = true
						for (p = string_length(tbx.line[l]) - 1; p > 1; p--)
							if (string_width(string_copy(tbx.line[l], 1, p)) < w)
								break
					}
					
					if (p = 0) // Cannot be wrapped
						continue
					
					if (l = tbx.lines - 1)
						a = true
					else
						a = !tbx.line_wrap[l + 1]
					
					if (a) // Create new line for wrapped text
					{ 
						for (b = tbx.lines; b > l; b--) // Push
						{
							tbx.line[b] = tbx.line[b - 1]
							tbx.line_wrap[b] = tbx.line_wrap[b - 1]
							tbx.line_single[b] = tbx.line_single[b - 1]
							
							// Move markers if affected
							if (textbox_select_mouseline = b)
								textbox_select_mouseline++
							
							if (textbox_select_clickline = b)
								textbox_select_clickline++
							
							if (textbox_select_endline = b)
								textbox_select_endline++
							
							if (textbox_select_startline = b)
								textbox_select_startline++
						}
						
						tbx.lines++
						tbx.line[l + 1] = string_delete(tbx.line[l], 1, p)
						tbx.line_wrap[l + 1] = true
						tbx.line_single[l + 1] = false
					}
					else
						tbx.line[l + 1] = string_delete(tbx.line[l], 1, p) + tbx.line[l + 1] // Add to existing
					
					// Move markers if affected
					a = string_length(tbx.line[l]) - p
					
					if (textbox_select_mouseline = l + 1)
						textbox_select_mousepos += a
					
					if (textbox_select_clickline = l + 1)
						textbox_select_clickpos += a
					
					if (textbox_select_endline = l + 1)
						textbox_select_endpos += a
					
					if (textbox_select_startline = l + 1)
						textbox_select_startpos += a
					
					if (textbox_select_mouseline = l && textbox_select_mousepos >= p)
					{
						textbox_select_mouseline++
						textbox_select_mousepos -= p
					}
					
					if (textbox_select_clickline = l && textbox_select_clickpos >= p)
					{
						textbox_select_clickline++
						textbox_select_clickpos -= p
					}
					
					if (textbox_select_endline = l && textbox_select_endpos >= p)
					{
						textbox_select_endline++
						textbox_select_endpos -= p
					}
					
					if (textbox_select_startline = l && textbox_select_startpos >= p)
					{
						textbox_select_startline++
						textbox_select_startpos -= p
					}
					
					tbx.line[l] = string_copy(tbx.line[l], 1, p)
				}
			}
			
			if (textbox_select_mouseline < tbx.start) // Move screen up
				tbx.start = textbox_select_mouseline
			
			if (textbox_select_mouseline >= tbx.start + floor(h / lineheight)) // Move screen down
				tbx.start = textbox_select_mouseline - floor(h / lineheight) + 1
		}
		
		tbx.start = max(0, min(tbx.start, tbx.lines - floor(h / lineheight)))
	}
	
	// Draw text and selection
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	
	var limit = string_width(string_limit(tbx.text + tbx.suffix, w, ""));
	textx = xx + ((w - min(w, limit)) * right)
	
	for (l = tbx.start * !tbx.single_line; l < tbx.lines; l++)
	{
		var ly = (l - tbx.start*!tbx.single_line) * lineheight; // Current line y value
		
		if (ly + lineheight > h) // Exit if beyond box
			break
		
		if ((window_busy = "" && window_focus = string(tbx)) || window_busy = string(tbx))
		{
			if (l = tbx.lines - 1) 
				hh = h-ly
			else
				hh = lineheight
			
			if ((mouse_x >= xx || window_busy = string(tbx)) &&
				(mouse_x < xx + w || window_busy = string(tbx)) &&
				(mouse_y >= yy + ly || (window_busy = string(tbx) && ly = 0)) &&
				(mouse_y < yy + ly + hh || (window_busy = string(tbx) && (ly + lineheight > h || l = tbx.lines - 1)))) // Cursor is inside line
			{
				if (mouse_left)
				{
					if (tbx.select_on_focus && textbox_lastfocus != tbx) // Select all
					{
						textbox_select_startline = 0
						textbox_select_startpos = 0
						textbox_select_endline = tbx.lines - 1
						textbox_select_endpos = string_length(tbx.line[textbox_select_endline])
						textbox_select_mouseline = textbox_select_endline
						textbox_select_mousepos = textbox_select_endpos
						textbox_select_clickline = 0
						textbox_select_clickpos = 0
						textbox_marker = current_time
						window_focus = string(tbx)
						window_busy = string(tbx) + "click"
					}
					else
					{
						window_busy = string(tbx)
						ww = 0
						for (a = tbx.start * tbx.single_line; a < string_length(tbx.line[l]); a++) // Find character over mouse
						{
							b = string_width(string_char_at(tbx.line[l], a + 1))
							ww += b
							if (mouse_x < textx + ww - b / 2)
								break
						}
						
						textbox_select_mouseline = l
						textbox_select_mousepos = a
						
						if (mouse_left_pressed)
						{
							if (textbox_select_clickline = textbox_select_mouseline && textbox_select_clickpos = textbox_select_mousepos) // Double click, word select
							{
								if (current_time - textbox_click < 500)
								{
									textbox_select_startline = textbox_select_mouseline
									textbox_select_startpos = max(1, textbox_select_mousepos - 1)
									textbox_select_endline = textbox_select_mouseline
									textbox_select_endpos = max(1, textbox_select_mousepos)
									
									while (true) // Look left / up for start position
									{
										c = string_char_at(tbx.line[textbox_select_startline], textbox_select_startpos)
										if (c = " " || c = ", " || c = "(" || c = ")" || c = "[" || c = "]" || c = "+")
											break
										
										textbox_select_startpos--
										if (textbox_select_startpos <= 0) // Jump up a line if it's a single word
										{
											if (textbox_select_startline = 0)
												break
											
											if (!tbx.line_single[textbox_select_startline - 1])
												break
											
											textbox_select_startline--
											textbox_select_startpos = string_length(tbx.line[textbox_select_startline])
										}
										
										if (textbox_select_startpos <= 0)
											break
									}
									
									while (true) // Look right / down for end position
									{ 
										c = string_char_at(tbx.line[textbox_select_endline], textbox_select_endpos)
										if (c = " " || c = ", " || c = "(" || c = ")" || c = "[" || c = "]" || c = "+")
											break
										
										textbox_select_endpos++
										if (textbox_select_endpos >= string_length(tbx.line[textbox_select_endline]))
										{
											if (textbox_select_endline = tbx.lines - 1)
												break
											
											if (!tbx.line_single[textbox_select_endline])
												break
											
											textbox_select_endline++
											textbox_select_endpos = 0
										}
										
										if (textbox_select_endpos >= string_length(tbx.line[textbox_select_endline]))
											break
									}
									
									textbox_select_mouseline = textbox_select_endline
									textbox_select_mousepos = textbox_select_endpos
									textbox_click = 0
									mouse_clear(mb_left)
								}
								else // Remove selection if clicking after word select
								{
									textbox_click = current_time
									textbox_select_startline = textbox_select_mouseline
									textbox_select_startpos = textbox_select_mousepos
									textbox_select_endline = textbox_select_mouseline
									textbox_select_endpos = textbox_select_mousepos
								}
							}
							else
							{
								textbox_click = current_time
								if (!keyboard_check(vk_shift) || textbox_lastfocus != tbx) // Drag selection if shift is held
								{ 
									textbox_select_startline = textbox_select_mouseline
									textbox_select_startpos = textbox_select_mousepos
									textbox_select_endline = textbox_select_mouseline
									textbox_select_endpos = textbox_select_mousepos
									textbox_select_clickline = textbox_select_mouseline
									textbox_select_clickpos = textbox_select_mousepos
								}
							}
							
							textbox_marker = current_time
							window_focus = string(tbx)
							textbox_lastfocus = tbx
						}
					}
				}
			}
		}
		
		if (tbx.single_line)
		{
			if (window_focus = string(tbx) && textbox_select_startpos != textbox_select_endpos)
			{
				for (a = 0; a < 3; a++)
					str[a] = ""
				
				if (textbox_select_endpos < tbx.start + 1 || textbox_select_startpos > tbx.start + 1 + tbx.chars) // Selection is outside
					str[0] = string_copy(tbx.line[0], tbx.start + 1, tbx.chars)
				
				else if (textbox_select_startpos <= tbx.start && textbox_select_endpos > tbx.start + tbx.chars) // All visible is selected
					str[1] = string_copy(tbx.line[0], tbx.start + 1, tbx.chars)
				else if (textbox_select_startpos > tbx.start && textbox_select_endpos < tbx.start + tbx.chars) // Only a part of visible is selected
				{
					str[0] = string_copy(tbx.line[0], tbx.start + 1, textbox_select_startpos - tbx.start)
					str[1] = string_copy(tbx.line[0], textbox_select_startpos + 1, textbox_select_endpos - textbox_select_startpos)
					str[2] = string_copy(tbx.line[0], textbox_select_endpos + 1, tbx.start + tbx.chars - textbox_select_endpos)
				}
				else if (textbox_select_startpos <= tbx.start) // Beginning is to the left
				{
					str[1] = string_copy(tbx.line[0], tbx.start + 1, textbox_select_endpos - tbx.start)
					str[2] = string_copy(tbx.line[0], textbox_select_endpos + 1, tbx.start + tbx.chars - textbox_select_endpos)
				}
				else // Ending is to the right
				{
					str[0] = string_copy(tbx.line[0], tbx.start + 1, textbox_select_startpos - tbx.start)
					str[1] = string_copy(tbx.line[0], textbox_select_startpos + 1, tbx.start + tbx.chars - textbox_select_startpos)
				}
				
				if (str[0] != "") // Text before or outside selection
				{
					draw_set_color(textnormal)
					draw_set_alpha(textnormala)
					draw_text(textx, yy, str[0])
				}
				
				if (str[1] != "") // Selected text
				{
					draw_set_color(highlight)
					draw_set_alpha(1)
					draw_rectangle(min(textx + w, textx + string_width(str[0])), yy, min(textx + w, textx + string_width(str[0] + str[1])), yy + lineheight, false)
					draw_set_color(texthighlight)
					draw_set_alpha(texthighlighta)
					draw_text(textx + string_width(str[0]), yy, str[1])
				}
				
				if (str[2] != "") // Text after selection
				{
					draw_set_color(textnormal)
					draw_set_alpha(textnormala)
					draw_text(textx + string_width(str[0] + str[1]), yy, str[2])
				}
			}
			else // Unselected
			{
				var text = string_copy(tbx.line[0], tbx.start + 1, tbx.chars);
				draw_set_color(textnormal)
				draw_set_alpha(textnormala)
				draw_text(textx, yy, text)
				
				// Suffix
				draw_set_color(textsuffix)
				draw_set_alpha(textsuffixa)
				draw_text(textx + string_width(text), yy, tbx.suffix)
			}
		}
		else
		{
			if (window_focus = string(tbx) && (textbox_select_startline != textbox_select_endline || textbox_select_startpos != textbox_select_endpos)) // This line is selected
			{
				for (a = 0; a < 3; a++)
					str[a] = ""
				
				if (textbox_select_startline = l && textbox_select_endline = l) // Same line
				{ 
					str[0] = string_copy(tbx.line[l], 1, textbox_select_startpos)
					str[1] = string_copy(tbx.line[l], textbox_select_startpos + 1, textbox_select_endpos - textbox_select_startpos)
					str[2] = string_delete(tbx.line[l], 1, textbox_select_endpos)
				}
				else if (textbox_select_startline = l) // Beginning line
				{
					str[0] = string_copy(tbx.line[l], 1, textbox_select_startpos)
					str[1] = string_delete(tbx.line[l], 1, textbox_select_startpos)
				}
				else if (textbox_select_endline = l) // Ending line
				{
					str[1] = string_copy(tbx.line[l], 1, textbox_select_endpos)
					str[2] = string_delete(tbx.line[l], 1, textbox_select_endpos)
				}
				else if (textbox_select_startline < l && textbox_select_endline > l) // Between
					str[1] = tbx.line[l]
				else // Outside
					str[0] = tbx.line[l]
				
				if (str[0] != "") // Text before or outside selection
				{
					draw_set_color(textnormal)
					draw_set_alpha(textnormala)
					draw_text(textx, yy + ly, str[0])
				}
				
				if (str[1] != "") // Selected text
				{
					draw_set_color(highlight)
					draw_set_alpha(1)
					draw_rectangle(min(textx + w, textx + string_width(str[0])), yy + ly, min(textx + w, textx + string_width(str[0] + str[1])), yy + ly + lineheight, false)
					draw_set_color(texthighlight)
					draw_set_alpha(texthighlighta)
					draw_text(textx + string_width(str[0]), yy + ly, str[1])
				}
				
				if (str[2] != "") // Text after selection
				{
					draw_set_color(textnormal)
					draw_set_alpha(textnormala)
					draw_text(textx + string_width(str[0] + str[1]), yy + ly, str[2])
				}
			} 
			else // Unselected line
			{
				draw_set_color(textnormal)
				draw_set_alpha(textnormala)
				draw_text(textx, yy + ly, tbx.line[l])
			}
		}
	}
	
	// Marker
	if (window_focus = string(tbx) && !tbx.read_only)
	{
		a = string_width(string_copy(tbx.line[textbox_select_mouseline], 1, textbox_select_mousepos))
		b = (textbox_select_mouseline - tbx.start) * lineheight
		
		if (tbx.single_line)
		{
			a -= string_width(string_copy(tbx.line[textbox_select_mouseline], 1, tbx.start))
			b = 0
		}
		
		if (a >= 0 && a <= w && b >= 0 && b + lineheight <= h && (current_time - textbox_marker) mod 1000 < 500)
		{
			draw_set_alpha(textnormala)
			draw_line_ext(textx + a, yy + b, textx + a, yy + b+lineheight, textnormal, 1)
		}
	}
	
	draw_set_color(c_white)
	draw_set_alpha(prevalpha)
	
	if (window_focus = string(tbx))
		textbox_lastfocus = tbx
	else if (window_focus = "")
		textbox_lastfocus = -1
	
	// Set cursor
	if (mouseover)
	{
		textbox_mouseover = tbx
		mouse_cursor = cr_beam
	}
	else if (textbox_mouseover = tbx)
	{
		textbox_mouseover = -1
		mouse_cursor = cr_default
	}
	
	tbx.last_text = tbx.text
	tbx.last_width = w
	
	if (textbox_jumpto = tbx)
		textbox_jumpto = -1
	
	return (inserttext != "" || deletetext != 0)
}
