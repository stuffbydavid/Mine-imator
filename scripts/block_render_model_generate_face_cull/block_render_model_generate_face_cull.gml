/// block_render_model_generate_face_cull(culldir)
/// @arg culldir
/// @desc Returns whether the current face should be culled.

var culldir = argument0;

switch (culldir)
{
	case e_dir.EAST:
	{
		if (!face_edge_xp || mc_builder.block_face_min_depth_xp = null || mc_builder.block_face_min_depth_xp > face_depth_xp)
			return false
			
		if (mc_builder.block_face_full_xp ||
			(mc_builder.block_face_min_y_xp <= from_y && mc_builder.block_face_max_y_xp >= to_y &&
			 mc_builder.block_face_min_z_xp <= from_z && mc_builder.block_face_max_z_xp >= to_z))
			return true
		
		break
	}
	
	case e_dir.WEST:
	{
		if (!face_edge_xn || mc_builder.block_face_min_depth_xn = null || mc_builder.block_face_min_depth_xn > face_depth_xn)
			return false
			
		if (mc_builder.block_face_full_xn ||
			(mc_builder.block_face_min_y_xn <= from_y && mc_builder.block_face_max_y_xn >= to_y &&
			 mc_builder.block_face_min_z_xn <= from_z && mc_builder.block_face_max_z_xn >= to_z))
			return true
		
		break
	}
	
	case e_dir.SOUTH:
	{
		if (!face_edge_yp || mc_builder.block_face_min_depth_yp = null || mc_builder.block_face_min_depth_yp > face_depth_yp)
			return false
		
		if (mc_builder.block_face_full_yp ||
			(mc_builder.block_face_min_x_yp <= from_x && mc_builder.block_face_max_x_yp >= to_x &&
			 mc_builder.block_face_min_z_yp <= from_z && mc_builder.block_face_max_z_yp >= to_z))
			return true
			
		break
	}
	
	case e_dir.NORTH:
	{
		if (!face_edge_yn || mc_builder.block_face_min_depth_yn = null || mc_builder.block_face_min_depth_yn > face_depth_yn)
			return false
		
		if (mc_builder.block_face_full_yn ||
			(mc_builder.block_face_min_x_yn <= from_x && mc_builder.block_face_max_x_yn >= to_x &&
			 mc_builder.block_face_min_z_yn <= from_z && mc_builder.block_face_max_z_yn >= to_z))
			return true
			
		break
	}
	
	case e_dir.UP:
	{
		if (!face_edge_zp || mc_builder.block_face_min_depth_zp = null || mc_builder.block_face_min_depth_zp > face_depth_zp)
			return false
		
		if (mc_builder.block_face_full_zp ||
			(mc_builder.block_face_min_x_zp <= from_x && mc_builder.block_face_max_x_zp >= to_x &&
			 mc_builder.block_face_min_y_zp <= from_y && mc_builder.block_face_max_y_zp >= to_y))
			return true
			
		break
	}
	
	case e_dir.DOWN:
	{
		if (!face_edge_zn || mc_builder.block_face_min_depth_zn = null || mc_builder.block_face_min_depth_zn > face_depth_zn)
			return false
		
		if (mc_builder.block_face_full_zn ||
			(mc_builder.block_face_min_x_zn <= from_x && mc_builder.block_face_max_x_zn >= to_x &&
			 mc_builder.block_face_min_y_zn <= from_y && mc_builder.block_face_max_y_zn >= to_y))
			return true
			
		break
	}
}

return false