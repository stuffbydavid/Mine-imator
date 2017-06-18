/// action_background_image_save_map()

var fn = file_dialog_save_image("cube");
if (fn != "")
    file_copy_lib(textures_directory + "cube.png", fn);
