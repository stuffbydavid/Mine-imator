/// project_read_timeline()

debug("Timeline object") debug_indent++

loaded = true
iid = iid_read()                                  debug("iid", iid)
iid_current = max(iid + 1, iid_current)
type = buffer_read_string_int()                   debug("type", type)
name = buffer_read_string_int()                   debug("name", name)
temp = iid_find(iid_read())                       debug("temp", temp)
text = buffer_read_string_int()                   debug("text", text)
color = buffer_read_int()
if (load_format < project_100debug) // Color too bright
{
    var hue = color_get_hue(color);
    color = make_color_hsv(hue, 255, 128)
}
debug("color", color)
lock = buffer_read_byte()                         debug("lock", lock)
if (load_format < project_100debug)
    lock = !lock
if (load_format >= project_100debug)
    depth = buffer_read_int()                     debug("depth", depth)

bodypart = buffer_read_short()                    debug("bodypart", bodypart)
part_of = iid_read()                              debug("part_of", part_of)
part_amount = buffer_read_short()                 debug("part_amount", part_amount) debug_indent++
for (var p = 0; p < part_amount; p++)
{
    part[p] = iid_read()
    if (!part[p])
        part[p] = null
    debug("part[" + string(p) + "]", part[p])
}
debug_indent--
if (temp && !part_of)
    temp.count++

hide = buffer_read_byte()                             debug("hide", hide)
if (load_format >= project_100demo3)
    project_read_value_types()
else
    tl_update_value_types()

if (load_format >= project_100demo4)
    project_read_values(id)

keyframe_amount = buffer_read_int()                   debug("keyframe_amount", keyframe_amount) debug_indent++
if (keyframe_amount = 0)
    for (var v = 0; v < values; v++)
        value_default[v] = value[v]

for (var k = 0; k < keyframe_amount; k++)
{
    with (new(obj_keyframe))
	{
        debug("Keyframe") debug_indent++
        pos = buffer_read_int() debug("pos", pos)
        id.tl = other.id
        index = k
        select = false
        sound_play_index = null
        loaded = true
        for (var v = 0; v < values; v++)
            value[v] = other.value[v]
        project_read_values(other.id)
        other.keyframe[k] = id
        debug_indent--
    }
}
debug_indent--
parent = iid_read() debug("parent", parent)

if (load_format >= project_100debug)
    parent_pos_read = buffer_read_int()
else
    parent_pos_read = null
debug("parent_pos", parent_pos)
lock_bend = buffer_read_byte()                        debug("lock_bend", lock_bend)

if (load_format < project_100debug) // Tree
{
    var am = buffer_read_int();
    for (var t = 0; t < am; t++)
        buffer_read_int()
}

tree_extend = buffer_read_byte()                      debug("tree_extend", tree_extend)
inherit_position = buffer_read_byte()                 debug("inherit_position", inherit_position)
inherit_rotation = buffer_read_byte()                 debug("inherit_rotation", inherit_rotation)
inherit_scale = buffer_read_byte()                    debug("inherit_scale", inherit_scale)
inherit_alpha = buffer_read_byte()                    debug("inherit_alpha", inherit_alpha)
inherit_color = buffer_read_byte()                    debug("inherit_color", inherit_color)
inherit_texture = buffer_read_byte()                  debug("inherit_texture", inherit_texture)
inherit_visibility = buffer_read_byte()               debug("inherit_visibility", inherit_visibility)
scale_resize = buffer_read_byte()                     debug("scale_resize", scale_resize)
rot_point_custom = buffer_read_byte()                 debug("rot_point_custom", rot_point_custom)
rot_point[XPOS] = buffer_read_double()
rot_point[YPOS] = buffer_read_double()
rot_point[ZPOS] = buffer_read_double()
if (rot_point_custom && load_format < project_100debug && type_is_shape(type))
{
    rot_point[XPOS] -= 8
    rot_point[ZPOS] -= 8
    if (type != "surface")
        rot_point[YPOS] -= 8
}
debug("rot_point", rot_point[XPOS], rot_point[YPOS], rot_point[ZPOS])
backfaces = buffer_read_byte()                        debug("backfaces", backfaces)
texture_blur = buffer_read_byte()                     debug("texture_blur", texture_blur)
if (load_format >= project_100debug)
    texture_filtering = buffer_read_byte()
else
    texture_filtering = (type = "scenery" || type = "block")
debug("texture_filtering", texture_filtering)

round_bending = buffer_read_byte()                    debug("round_bending", round_bending)
shadows = buffer_read_byte()                          debug("shadows", shadows)
if (load_format >= project_100debug)
{
    ssao = buffer_read_byte()                         debug("ssao", ssao)
    if (load_format >= project_105_2)
        fog = buffer_read_byte()                      debug("fog", fog)
    wind = buffer_read_byte()                         debug("wind", wind)
    wind_amount = buffer_read_double()                debug("wind_amount", wind_amount)
}
wind_terrain = buffer_read_byte()                     debug("wind_terrain", wind_terrain)

debug_indent--
