/// tl_value_spawn()

if (type = "camera")
{
    if (!app.setting_spawn_cameras)
        return 0
		
    value[XPOS] = app.cam_work_from[X]
    value[YPOS] = app.cam_work_from[Y]
    value[ZPOS] = app.cam_work_from[Z]
    value[XROT] = -app.cam_work_angle_look_z
    value[YROT] = app.cam_work_roll
    value[ZROT] = app.cam_work_angle_look_xy - 90
}
else if (parent = app && !part_of && type != "folder")
{
    if (!app.setting_spawn_objects)
        return 0
		
    value[XPOS] = app.cam_work_focus[X]
    value[YPOS] = app.cam_work_focus[Y]
    value[ZPOS] = max(0, app.cam_work_focus[Z] - 16)
}

value_default[XPOS] = value[XPOS]
value_default[YPOS] = value[YPOS]
value_default[ZPOS] = value[ZPOS]
value_default[XROT] = value[XROT]
value_default[YROT] = value[YROT]
value_default[ZROT] = value[ZROT]
