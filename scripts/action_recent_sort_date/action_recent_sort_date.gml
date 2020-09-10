/// action_recent_sort_date()

if (recent_sort_mode = e_recent_sort.date_descend)
	recent_sort_mode = e_recent_sort.date_ascend
else
	recent_sort_mode = e_recent_sort.date_descend

recent_update()
