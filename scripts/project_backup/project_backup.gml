/// project_backup()

var fn = project_folder + "\\" + filename_name(project_folder);

log("Backup", fn)

for (var b = setting_backup_amount - 1; b > 0; b--)
	if (file_exists_lib(fn + ".backup" + string(b)))
		file_rename_lib(fn + ".backup" + string(b), fn + ".backup" + string(b + 1))
	
project_save(fn + ".backup" + test(setting_backup_amount > 1, "1", ""))
project_reset_backup()

log("Backup saved")
