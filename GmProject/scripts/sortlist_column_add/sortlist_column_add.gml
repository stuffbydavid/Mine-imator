/// sortlist_column_add(sortlist, name, x)
/// @arg sortlist
/// @arg name
/// @arg x
/// @desc Adds a new column with the given name.

function sortlist_column_add(slist, name, xx)
{
	slist.column_name[slist.columns] = name
	slist.column_x[slist.columns] = xx
	slist.column_w[slist.columns] = 0
	slist.columns++
}
