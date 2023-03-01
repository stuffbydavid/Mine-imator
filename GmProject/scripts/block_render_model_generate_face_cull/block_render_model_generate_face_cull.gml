/// block_render_model_generate_face_cull(model, element, culldir)
/// @arg culldir
/// @desc Returns whether the current face should be culled.
function block_render_model_generate_face_cull(model, el, culldir) {

	switch (culldir)
	{
		case e_dir.EAST:
		{
			if (!el.face_edge_xp || block_face_min_depth_xp = null || block_face_min_depth_xp > model.face_min_depth_xp)
				return false
			
			if (block_current != null && block_current.type = "leaves" && block_face_min_depth_xp > e_block_depth.DEPTH0)
				return false
			
			if (block_face_full_xp || (block_face_min_xp <= el.from_z && block_face_max_xp >= el.to_z))
				return true
		
			break
		}
	
		case e_dir.WEST:
		{
			if (!el.face_edge_xn || block_face_min_depth_xn = null || block_face_min_depth_xn > model.face_min_depth_xn)
				return false
			
			if (block_current != null && block_current.type = "leaves" && block_face_min_depth_xn > e_block_depth.DEPTH0)
				return false
			
			if (block_face_full_xn || (block_face_min_xn <= el.from_z && block_face_max_xn >= el.to_z))
				return true
		
			break
		}
	
		case e_dir.SOUTH:
		{
			if (!el.face_edge_yp || block_face_min_depth_yp = null || block_face_min_depth_yp > model.face_min_depth_yp)
				return false
			
			if (block_current != null && block_current.type = "leaves" && block_face_min_depth_yp > e_block_depth.DEPTH0)
				return false
		
			if (block_face_full_yp || (block_face_min_yp <= el.from_z && block_face_max_yp >= el.to_z))
				return true
			
			break
		}
	
		case e_dir.NORTH:
		{
			if (!el.face_edge_yn || block_face_min_depth_yn = null || block_face_min_depth_yn > model.face_min_depth_yn)
				return false
			
			if (block_current != null && block_current.type = "leaves" && block_face_min_depth_yn > e_block_depth.DEPTH0)
				return false
		
			if (block_face_full_yn || (block_face_min_yn <= el.from_z && block_face_max_yn >= el.to_z))
				return true
			
			break
		}
	
		case e_dir.UP:
		{
			if (!el.face_edge_zp || block_face_min_depth_zp = null || block_face_min_depth_zp > model.face_min_depth_zp)
				return false
			
			if (block_current != null && block_current.type = "leaves" && block_face_min_depth_zp > e_block_depth.DEPTH0)
				return false
		
			if (block_face_full_zp || (block_face_min_zp <= el.from_y && block_face_max_zp >= el.to_y))
				return true
			
			break
		}
	
		case e_dir.DOWN:
		{
			if (!el.face_edge_zn || block_face_min_depth_zn = null || block_face_min_depth_zn > model.face_min_depth_zn)
				return false
			
			if (block_current != null && block_current.type = "leaves" && block_face_min_depth_zn > e_block_depth.DEPTH0)
				return false
				
			if (block_face_full_zn || (block_face_min_zn <= el.from_y && block_face_max_zn >= el.to_y))
				return true
			
			break
		}
	}

	return false


}
