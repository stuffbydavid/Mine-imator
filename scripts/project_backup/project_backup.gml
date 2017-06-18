/// project_backup()

var fn = project_folder + "\\" + filename_name(project_folder);

log("Backup", fn)

for (var b = setting_backup_amount - 1; b > 0; b--)
    if (file_exists_lib(fn + ".mbackup" + string(b)))
        file_rename_lib(fn + ".mbackup" + string(b), fn + ".mbackup" + string(b + 1))
	
project_save(fn + ".mbackup" + test(setting_backup_amount > 1, "1", ""))
project_reset_backup()

log("Backup saved")
