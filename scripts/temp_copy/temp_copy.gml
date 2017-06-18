/// temp_copy(to)
/// @arg to
/// @desc Copies all the variables into the given object.

var to = argument0;

to.type = type
to.name = name

to.char_skin = char_skin
to.char_model = char_model
to.char_bodypart = char_bodypart

to.item_tex = item_tex
to.item_sheet = item_sheet
to.item_n = item_n
to.item_3d = item_3d
to.item_face_camera = item_face_camera
to.item_bounce = item_bounce

to.block_id = block_id
to.block_data = block_data
to.block_tex = block_tex

to.scenery = scenery

to.repeat_toggle = repeat_toggle
to.repeat_x = repeat_x
to.repeat_y = repeat_y
to.repeat_z = repeat_z

to.shape_tex = shape_tex
to.shape_tex_mapped = shape_tex_mapped
to.shape_tex_hoffset = shape_tex_hoffset
to.shape_tex_voffset = shape_tex_voffset
to.shape_tex_hrepeat = shape_tex_hrepeat
to.shape_tex_vrepeat = shape_tex_vrepeat
to.shape_tex_hmirror = shape_tex_hmirror
to.shape_tex_vmirror = shape_tex_vmirror
to.shape_closed = shape_closed
to.shape_invert = shape_invert
to.shape_detail = shape_detail
to.shape_face_camera = shape_face_camera

to.text_font = text_font
to.text_face_camera = text_face_camera

if (type = "particles")
	temp_particles_copy(to)
