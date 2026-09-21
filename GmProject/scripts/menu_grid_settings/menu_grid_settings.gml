/// menu_grid_settings()

function menu_grid_settings()
{
    draw_set_font(font_label)
    
	var draggerwid = text_max_width("viewgridrows", "viewgridcolumns") + 16 + dragger_width;
    var menuwid = text_max_width("viewcompositionguide") + 16 + 140
    
    // Composition guide dropdown
    tab_control_menu()
    draw_button_menu("viewcompositionguide", e_menu.LIST, dx, dy, dw, 24, project_composition_guide, text_get("viewcompositionguidetype" + composition_guide_list[|project_composition_guide]), action_project_composition_guide)
    tab_next()
	
    // Only show rows/columns if using grid (Rule of Thirds)
    if (project_composition_guide = e_composition_guide.RULE_OF_THIRDS)
    {
        tab_control_dragger()
        draw_dragger("viewgridcolumns", dx, dy, dragger_width, project_grid_columns, 0.05, 1, 10, 3, 1, tbx_grid_columns, action_project_grid_columns, null, true)
        tab_next()
		
        tab_control_dragger()
        draw_dragger("viewgridrows", dx, dy, dragger_width, project_grid_rows, 0.05, 1, 10, 3, 1, tbx_grid_rows, action_project_grid_rows, null, true)
        tab_next()
    }
	
	if (project_composition_guide = e_composition_guide.CIRCULAR)
    {
        tab_control_dragger()
        draw_dragger("viewgridrows", dx, dy, dragger_width, project_grid_rows, 0.05, 1, 10, 3, 1, tbx_grid_rows, action_project_grid_rows, null, true)
        tab_next()
	}
	
    tab_control_meter()
    draw_meter("viewgridalpha", dx, dy, dw, round(project_grid_alpha * 100), 0, 100, 80, 1, tbx_grid_alpha, action_project_grid_alpha)
    tab_next()
    
    settings_menu_w = (max(draggerwid, menuwid) + 24)
}