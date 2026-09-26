/// textbox_update()

function textbox_update()
{
	if (textbox_jump || (textbox_isediting && keyboard_check_pressed(vk_tab)))
	{
		if (textbox_jump)
		{
			// Find textbox in list
			var tbxpos, tbxdata, tab, tabstart, tbx, move;
			tbxpos = 0
			for (; tbxpos < ds_list_size(textbox_list); tbxpos++)
			{
				tbxdata = textbox_list[|tbxpos]
				if (tbxdata[0] = textbox_lastfocus)
					break;
			}

			move = (keyboard_check(vk_shift) ? -1 : 1)
			tabstart = tbxdata[1]
			tab = -1

			// Only move to textbox within current tab
			while (tabstart != tab)
			{
				tbxpos += move
				tbxpos = mod_fix(tbxpos, ds_list_size(textbox_list))

				tbxdata = textbox_list[|tbxpos]
				tab = tbxdata[1]
			}

			// Update data
			tab = tbxdata[1]
			if (tab != null && tab.scroll != null && tab.scroll.needed)
				tab.scroll.value_goal = (tbxdata[2] - (tbxdata[3] - tab.scroll.value)) - (floor(tbxdata[4]/2))

			tbx = tbxdata[0]
			window_focus = string(tbx)
			textbox_jumpto = tbx
			ds_list_clear(textbox_list)
			textbox_jump = false
		}
		else
			textbox_jump = true
	}

	if (textbox_jumpto = -1 && textbox_isediting && !textbox_isediting_respond)
	{
		textbox_isediting = false
		if (window_busy = "")
			window_focus = ""
	}

	// Unfocus textbox
	if (textbox_isediting && keyboard_check_pressed(vk_escape))
	{
		window_focus = ""
		textbox_lastfocus = -1
		textbox_isediting = false
		textbox_input = ""
		return true
	}

	textbox_isediting_respond = false
	return false
}
