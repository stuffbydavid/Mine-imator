function minecraft_get_pack_image(pack)
{
	if (is_undefined(pack_image_map[?pack]))
	{
		texture_page_reset()
		
		var packimage;
		if (zip_extract_file(packs_directory_get() + pack, mc_pack_image_file, temp_image))
			packimage = texture_create(temp_image, false)
		else
			packimage = texture_sprite(spr_unknown_pack)
					
		pack_image_map[?pack] = packimage
		
		return packimage
	}
	
	return pack_image_map[?pack]
}
