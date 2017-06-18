/// res_copy(to)
/// @arg to


// TO DO

var to = argument0;

to.iid = iid
to.type = type
to.filename = filename
to.filename_out = filename_out
to.display_name = display_name
to.pack_description = pack_description
to.is_skin = is_skin
to.block_frames = block_frames
if (type = "pack")
    for (var b = 0; b < 32 * 16; b++)
        to.block_ani[b] = block_ani[b]
to.block_format = block_format
