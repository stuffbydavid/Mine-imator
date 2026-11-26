function action_res_project_pack(value)
{
	var res;

	if (history_undo)
		res = history_undo_res()
	else if (history_redo)
		res = history_redo_res()
	else
	{
		res = value ? res_edit : mc_res
		history_set_res(action_res_project_pack, "", project_pack, res)
	}

	action_project_pack(res, false)
}
