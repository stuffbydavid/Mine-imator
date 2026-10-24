/// @desc Reads linear viewport depth and packed object/face ID from the latest available render.

function view_get_place_pixel(view, xx, yy)
{
	if (!surface_exists(view.surface_place_id))
		return [ 1, 0, place_dir_none ]
	
	var pixel, packed, tl, face, pixelstate;
	pixelstate = null
	
	// Async pixel lookup in first-person build mode
	if (is_cpp() && build_first_person && view = view_main && !mouse_left_pressed && !mouse_right_pressed && !mouse_middle_pressed)
	{
		// Surface changes, reset asynchronous list
		var listsize = 8;
		if (view.surface_place_async_id != view.surface_place_id)
		{
			view.surface_place_async_id = view.surface_place_id
			view.surface_place_async_list = array_create(listsize)
		}
		
		// Read single pixel asynchronously
		pixel = surface_getpixel_async(view.surface_place_id, xx, yy)
		if (pixel[5] > 0)
		{
			// Keep the render state used by this readback
			view.surface_place_async_list[@ pixel[5] mod listsize] = [
				pixel[5], view.surface_place_depth_near, view.surface_place_depth_far,
				view.surface_place_proj_matrix, view.surface_place_view_matrix, view.surface_place_tl_list,
				xx, yy, view.surface_width, view.surface_height
			]
		}
		
		if (pixel[4] = 0)
			return []
		
		pixelstate = view.surface_place_async_list[@ pixel[4] mod listsize]
		
		if (!is_array(pixelstate) || pixelstate[0] != pixel[4])
			return []
	}
	
	// Regular build mode and GameMaker use a synchronous lookup
	else
		pixel = surface_getpixel(view.surface_place_id, xx, yy)
	
	// Unpack data
	packed = round(pixel[1])
	tl = packed & ((1 << place_id_bits) - 1)
	face = (packed >> place_id_bits) & 7
	
	if (is_array(pixelstate))
		return [ pixel[0], tl, face, pixelstate ]
	
	return [ pixel[0], tl, face ]
}
