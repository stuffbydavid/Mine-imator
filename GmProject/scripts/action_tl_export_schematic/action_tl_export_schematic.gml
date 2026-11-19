function action_tl_export_schematic()
{
	if (tl_edit = null || !type_is_structure(tl_edit.type))
		return 0

	var fn = file_dialog_save_schematic(tl_edit.display_name + ".schem", ".schem");
	if (fn = "")
		return 0

	with (tl_edit)
	{
		tl_update_matrix()
		tl_export_schematic(filename_new_ext(fn, ".schem"))
	}
}
