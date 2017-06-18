/// popup_newproject_draw()
/// @desc Settings for starting a new project.

var capwid = text_caption_width("newprojectname", "newprojectauthor", "newprojectdescription", "newprojectfolder");

// Name
if (draw_inputbox("newprojectname", dx, dy, dw, "", popup.tbx_name, null, capwid))
    popup.folder = filename_valid(popup.tbx_name.text)
dy += 30

// Author
draw_inputbox("newprojectauthor", dx, dy, dw, "", popup.tbx_author, null, capwid)
dy += 30

// Description
draw_inputbox("newprojectdescription", dx, dy, dw, "", popup.tbx_description, null, capwid, 152)
dy += 160

// Folder
draw_label(text_get("newprojectfolder") + ":", dx, dy + 4)
draw_label(directory_name(setting_project_folder) + string_remove_newline(popup.folder), dx + capwid, dy + 4)
tip_set(text_get("newprojectfoldertip"), dx, dy, dw - 60, 24)

dw = text_caption_width("newprojectfolderchange")
dx = content_x + content_width - dw
if (draw_button_normal("newprojectfolderchange", dx, dy, dw, 24))
{
    var fn = file_dialog_save_project(popup.folder)
    if (fn != "")
	{
        popup.folder = filename_name(fn)
        action_setting_project_folder(filename_path(fn))
    }
}

// Create
dw = 100
dh = 32
dx = content_x + content_width / 2-dw - 4
dy = content_y + content_height - 32
if (draw_button_normal("newprojectcreate", dx, dy, dw, 32))
{
    popup_switch_to = null
    project_create()
}

// Cancel
dx = content_x + content_width / 2+4
if (draw_button_normal("newprojectcancel", dx, dy, dw, 32))
{ 
    if (popup_switch_from = popup_startup)
        popup_switch(popup_switch_from)
    else
        popup_close()
}
