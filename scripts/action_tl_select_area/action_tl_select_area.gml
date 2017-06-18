/// action_tl_select_area(starttimeline, endtimeline)
/// @arg starttimeline
/// @arg endtimeline

if (history_undo)
{
    with (history_data)
        history_restore_tl_select()
}
else if (history_redo)
{
    with (history_data)
        history_restore_tl_select_new()
}
else
{
    var stl, etl, hobj;
    stl = argument0
    etl = argument1
    hobj = history_set(action_tl_select_area)
    
    with (hobj)
        history_save_tl_select()
        
    for (var t = stl; t <= etl; t++)
        with (tree_list[t])
            tl_select()
            
    with (hobj)
        history_save_tl_select_new()
}

app_update_tl_edit()
