/// tl_update_matrix()
/// @desc Updates matrixes and positions.

if (object_index != app && update_matrix)
{
    var pos, rot, sca, tl, inhalpha, inhcolor, inhvis, inhtex;
    pos = point3D(value[XPOS], value[YPOS], value[ZPOS])
	rot = vec3(value[XROT], value[YROT], value[ZROT])
	sca = vec3(value[XSCA], value[YSCA], value[ZSCA])
	
    // Parent matrix
    if (parent != app)
	{
        matrix_parent = parent.matrix
        
        // Parent is a body part and we're locked to bended half
        if (parent.type = "bodypart" && lock_bend)
            matrix_parent = matrix_multiply(model_bend_matrix(parent.bodypart, parent.value[BENDANGLE]), matrix_parent)
    }
	else
		matrix_parent = IDENTITY
    
    // Add body part transformations
	if (type = "bodypart")
	{
		matrix_parent = matrix_multiply(matrix_create(bodypart.position, vec3(0), bodypart.scale), matrix_parent)
		rot = vec3_add(rot, bodypart.rotation)
	}
		
    // Create main matrix
	matrix = matrix_multiply(matrix_create(pos, rot ,sca), matrix_parent)
    
    // No scale TODO
    if (scale_resize || !inherit_scale)
	{
        /*// Actual scale
	    tl = id
	    while (1)
		{
	        var par = tl.parent;
	        if (!tl.inherit_scale || par = app)
	            break
			sca = vec3_mul(sca, vec3(par.value[XSCA], par.value[YSCA], par.value[ZSCA]))
	        tl = par
	    }
		matrix_remove_scale(matrix_parent)
        matrix_remove_scale(matrix)
        //var matrixnoscale = matrix_multiply(tl_base_matrix(true, true, false, true), matrix_parent);
        //for (var p = 0; p < 11; p++)
        //    matrix[p] = matrixnoscale[p]
        if (inherit_scale)
            matrix = matrix_multiply(matrix_create(point3D(0, 0, 0), vec3(0), sca), matrix)
        else
            matrix = matrix_multiply(matrix_create(point3D(0, 0, 0), vec3(0), vec3(value[XSCA], value[YSCA], value[ZSCA])), matrix)*/ 
    }
    
    // Remove old rotation and re-add own
    if (!inherit_rotation)
	{
        matrix_remove_rotation(matrix)
        matrix = matrix_multiply(matrix_create(point3D(0, 0, 0), vec3(value[XROT], value[YROT], value[ZROT]), vec3(1)), matrix) 
    }
    
    // Replace position
    if (!inherit_position)
	{
        matrix[MATX] = value[XPOS]
        matrix[MATY] = value[YPOS]
        matrix[MATZ] = value[ZPOS]
    }
    
    // Create bend matrix
    if (type = "bodypart")
        matrix_bend = matrix_multiply(model_bend_matrix(bodypart, value[BENDANGLE]), matrix)
    
    // Create rotation point
    if (type = "camera" && value[CAMROTATE])
	{
        pos_rotate = point3D(matrix[MATX], matrix[MATY], matrix[MATZ])
        matrix[MATX] += lengthdir_x(value[CAMROTATEDISTANCE], value[CAMROTATEXYANGLE] + 90) * lengthdir_x(1, value[CAMROTATEZANGLE])
        matrix[MATY] += lengthdir_y(value[CAMROTATEDISTANCE], value[CAMROTATEXYANGLE] + 90) * lengthdir_x(1, value[CAMROTATEZANGLE])
        matrix[MATZ] += lengthdir_z(value[CAMROTATEDISTANCE], value[CAMROTATEZANGLE])
    }
    
    // Set world position
    pos = point3D(matrix[MATX], matrix[MATY], matrix[MATZ])
    
    // Scale for position controls
    value_inherit[XSCA] = 1
    value_inherit[YSCA] = 1
    value_inherit[ZSCA] = 1
    tl = id
    while (1)
	{
        var par = tl.parent;
        if (par = app)
            break
        value_inherit[XSCA] *= par.value[XSCA]
        value_inherit[YSCA] *= par.value[YSCA]
        value_inherit[ZSCA] *= par.value[ZSCA]
        if (!par.inherit_scale)
            break
        tl = par
    }
    
    // Inherit colors
    value_inherit[VISIBLE] = value[VISIBLE] // Multiplied
    value_inherit[ALPHA] = value[ALPHA] // Multiplied
    value_inherit[RGBADD] = value[RGBADD] // Added
    value_inherit[RGBSUB] = value[RGBSUB] // Added
    value_inherit[RGBMUL] = value[RGBMUL] // Multiplied
    value_inherit[HSBADD] = value[HSBADD] // Added
    value_inherit[HSBSUB] = value[HSBSUB] // Added
    value_inherit[HSBMUL] = value[HSBMUL] // Multiplied
    value_inherit[MIXCOLOR] = value[MIXCOLOR] // Added
    value_inherit[MIXPERCENT] = value[MIXPERCENT] // Added
    value_inherit[BRIGHTNESS] = value[BRIGHTNESS] // Added
    value_inherit[TEXTUREOBJ] = value[TEXTUREOBJ] // Overwritten
    
    inhalpha = true
    inhcolor = true
    inhvis = true
    inhtex = true
    tl = id
    while (true)
	{
        var par = tl.parent;
        if (par = app)
            break
        
        if (!tl.inherit_alpha)
            inhalpha = false
        if (!tl.inherit_color)
            inhcolor = false
        if (!tl.inherit_visibility)
            inhvis = false
        if (!tl.inherit_texture || tl.value[TEXTUREOBJ] >= 0)
            inhtex = false
        
        if (inhalpha)
            value_inherit[ALPHA] *= par.value[ALPHA]
        if (inhcolor)
		{
            value_inherit[RGBADD] = color_add(value_inherit[RGBADD], par.value[RGBADD])
            value_inherit[RGBSUB] = color_add(value_inherit[RGBSUB], par.value[RGBSUB])
            value_inherit[RGBMUL] = color_multiply(value_inherit[RGBMUL], par.value[RGBMUL])
            value_inherit[HSBADD] = color_add(value_inherit[HSBADD], par.value[HSBADD])
            value_inherit[HSBSUB] = color_add(value_inherit[HSBSUB], par.value[HSBSUB])
            value_inherit[HSBMUL] = color_multiply(value_inherit[HSBMUL], par.value[HSBMUL])
            value_inherit[MIXCOLOR] = color_add(value_inherit[MIXCOLOR], par.value[MIXCOLOR])
            value_inherit[MIXPERCENT] = clamp(value_inherit[MIXPERCENT] + par.value[MIXPERCENT], 0, 1)
            value_inherit[BRIGHTNESS] = clamp(value_inherit[BRIGHTNESS] + par.value[BRIGHTNESS], 0, 1)
        }
        if (inhvis)
            value_inherit[VISIBLE] *= par.value[VISIBLE]
        if (inhtex)
            value_inherit[TEXTUREOBJ] = par.value[TEXTUREOBJ]
        tl = par
    }
    
    // Update bend vbuffer
    //tl_update_bend(false)
}

// Update children
for (var t = 0; t < tree_amount; t++)
{
    if (object_index != app && update_matrix)
        tree[t].update_matrix = true
    with (tree[t])
        tl_update_matrix()
}

update_matrix = false
