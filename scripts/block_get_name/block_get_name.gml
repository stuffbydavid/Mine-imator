/// block_get_name(id, data)
/// @arg id
/// @arg data

var bid, bdata, name;
bid = argument0
bdata = argument1
name = "block" + mc_version.block_map[?bid].data_name[bdata]

if (!text_exists(name))
	return mc_version.block_map[?bid].data_default_name[bdata]
else
	return text_get(name)