/// project_create()
/// @desc Creates a new project from the newproject dialog settings.

var dirname = setting_project_folder + popup_newproject.folder;

if (popup_newproject.folder = "")
{
    error("errornewprojectinvalid")
    return 0
}

if (directory_exists_lib(setting_project_folder + popup_newproject.folder))
{
    error("errornewprojectexists")
    return 0
}

directory_create_lib(setting_project_folder)
directory_create_lib(dirname)

if (!directory_exists_lib(dirname))
{
    error("errornewprojectaccess")
    return 0
}

log("Creating project", dirname)

project_reset()

project_name = popup_newproject.tbx_name.text;
project_author = popup_newproject.tbx_author.text;
project_description = popup_newproject.tbx_description.text;

project_folder = dirname
project_file = project_folder + "\\" + filename_valid(project_name) + ".mproj"

popup_close()

project_save("")

alert_show(text_get("alertprojectcreatedtitle"), text_get("alertprojectcreatedtext"), 0, "alertprojectcreatedbutton", project_folder, 5000)
