/// action_recent_sort_filename()

if (recent_sort_mode = e_recent_sort.filename_descend)
	recent_sort_mode = e_recent_sort.filename_ascend
else
	recent_sort_mode = e_recent_sort.filename_descend

recent_update()
