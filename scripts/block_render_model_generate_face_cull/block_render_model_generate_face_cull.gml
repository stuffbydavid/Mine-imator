/// block_render_model_generate_face_cull(culldir)
/// @arg culldir
/// @desc Returns whether the current face should be culled.

function block_render_model_generate_face_cull(culldir)
{
	switch (culldir)
	{
		case e_dir.EAST:
		{
			if (!face_edge_xp || mc_builder.block_face_min_depth_xp = null || mc_builder.block_face_min_depth_xp > other.face_min_depth_xp)
				return false
			
			if (mc_builder.block_current != null && mc_builder.block_current.type = "leaves" && mc_builder.block_face_min_depth_xp > e_block_depth.DEPTH0)
				return false
			
			if (mc_builder.block_face_full_xp || (mc_builder.block_face_min_xp <= from_z && mc_builder.block_face_max_xp >= to_z))
				return true
			
			break
		}
		
		case e_dir.WEST:
		{
			if (!face_edge_xn || mc_builder.block_face_min_depth_xn = null || mc_builder.block_face_min_depth_xn > other.face_min_depth_xn)
				return false
			
			if (mc_builder.block_current != null && mc_builder.block_current.type = "leaves" && mc_builder.block_face_min_depth_xn > e_block_depth.DEPTH0)
				return false
			
			if (mc_builder.block_face_full_xn || (mc_builder.block_face_min_xn <= from_z && mc_builder.block_face_max_xn >= to_z))
				return true
			
			break
		}
		
		case e_dir.SOUTH:
		{
			if (!face_edge_yp || mc_builder.block_face_min_depth_yp = null || mc_builder.block_face_min_depth_yp > other.face_min_depth_yp)
				return false
			
			if (mc_builder.block_current != null && mc_builder.block_current.type = "leaves" && mc_builder.block_face_min_depth_yp > e_block_depth.DEPTH0)
				return false
			
			if (mc_builder.block_face_full_yp || (mc_builder.block_face_min_yp <= from_z && mc_builder.block_face_max_yp >= to_z))
				return true
			
			break
		}
		
		case e_dir.NORTH:
		{
			if (!face_edge_yn || mc_builder.block_face_min_depth_yn = null || mc_builder.block_face_min_depth_yn > other.face_min_depth_yn)
				return false
			
			if (mc_builder.block_current != null && mc_builder.block_current.type = "leaves" && mc_builder.block_face_min_depth_yn > e_block_depth.DEPTH0)
				return false
			
			if (mc_builder.block_face_full_yn || (mc_builder.block_face_min_yn <= from_z && mc_builder.block_face_max_yn >= to_z))
				return true
			
			break
		}
		
		case e_dir.UP:
		{
			if (!face_edge_zp || mc_builder.block_face_min_depth_zp = null || mc_builder.block_face_min_depth_zp > other.face_min_depth_zp)
				return false
			
			if (mc_builder.block_current != null && mc_builder.block_current.type = "leaves" && mc_builder.block_face_min_depth_zp > e_block_depth.DEPTH0)
				return false
			
			if (mc_builder.block_face_full_zp || (mc_builder.block_face_min_zp <= from_y && mc_builder.block_face_max_zp >= to_y))
				return true
			
			break
		}
		
		case e_dir.DOWN:
		{
			if (!face_edge_zn || mc_builder.block_face_min_depth_zn = null || mc_builder.block_face_min_depth_zn > other.face_min_depth_zn)
				return false
			
			if (mc_builder.block_current != null && mc_builder.block_current.type = "leaves" && mc_builder.block_face_min_depth_zn > e_block_depth.DEPTH0)
				return 0
			
			if (mc_builder.block_face_full_zn || (mc_builder.block_face_min_zn <= from_y && mc_builder.block_face_max_zn >= to_y))
				return true
			
			break
		}
	}
	
	return false
}
