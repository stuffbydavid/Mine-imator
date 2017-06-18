/// action_lib_shape_save_map()

var fn = file_dialog_save_image(temp_edit.type);
if (fn != "")
    file_copy_lib(textures_directory + temp_edit.type + ".png", fn);
