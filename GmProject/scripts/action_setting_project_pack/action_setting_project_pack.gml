/// action_setting_project_pack(pack)
/// @arg filename

function action_setting_project_pack(pack)
{
	if (!is_string(pack) && pack = e_option.BROWSE)
	{
		var fn = file_dialog_open_pack();
		if (!file_exists_lib(fn))
			return 0
		
		directory_create_lib(packs_directory_get())
		
		// Copy chosen zip to Packs/
		var packfn = packs_directory_get() + filename_name(fn)
		file_copy_lib(fn, packfn)
		
		if (!file_exists_lib(packfn))
			return 0
				
		pack = filename_name(fn)
	}
	
	setting_project_pack = pack
}
