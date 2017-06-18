/// sortlist_column_add(sortlist, name, x)
/// @arg sortlist
/// @arg name
/// @arg x
/// @desc Adds a new column with the given name.

var slist = argument0;

slist.column_name[slist.columns] = argument1
slist.column_x[slist.columns] = argument2
slist.column_w[slist.columns] = 0
slist.columns++
