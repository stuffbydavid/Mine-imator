/// history_undo_res()

if (history_data.fn != "" && !history_data.replaced)
{
    with (iid_find(history_data.newres))
	{
        res_deletefiles()
        instance_destroy()
    }
}

return iid_find(history_data.oldres)