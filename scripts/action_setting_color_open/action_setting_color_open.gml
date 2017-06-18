/// action_setting_color_open()

var fn = file_dialog_open_color();

if (!file_exists_lib(fn))
    return 0

buffer_current = buffer_import(fn)
settings_read_colors()
buffer_delete(buffer_current)
