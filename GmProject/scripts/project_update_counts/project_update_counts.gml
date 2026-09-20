/// project_update_counts()
/// @desc Perform a project-wide update of all usage counters for templates and resources.

function project_update_counts()
{
	// Reset counters
	with (obj_template)
		count = 0
	with (obj_resource)
		count = 0

	debug_timer_start()
	
	// Count resources used by templates
	with (obj_template)
	{
		if (creator = app.bench_settings)
			continue

		var refs = array(
			model,
			model_tex,
			item_tex,
			block_tex,
			scenery,
			shape_tex,
			text_font
		);
		
		if (app.project_render_material_maps)
		{
			array_add(refs, model_tex_material)
			array_add(refs, model_tex_normal)
			array_add(refs, item_tex_material)
			array_add(refs, item_tex_normal)
			array_add(refs, block_tex_material)
			array_add(refs, block_tex_normal)
			array_add(refs, shape_tex_material)
			array_add(refs, shape_tex_normal)
		}
		
		for (var i = 0; i < array_length(refs); i++)
		{
			if (refs[i] = null)
				continue
				
			var res = res_eval(refs[i])
			if (instance_exists(res) && res.object_index = obj_resource)
				res.count++
		}
	}
	
	// Count resources used by particle types
	with (obj_particle_type)
	{
		if (creator != null && instance_exists(creator) && creator.creator = app.bench_settings)
			continue

		if (temp > 0 && instance_exists(temp) && temp.object_index = obj_template)
			temp.count++

		var refs = array(
			sprite_tex,
			sprite_template_tex
		);
		
		for (var i = 0; i < array_length(refs); i++)
		{
			if (refs[i] = null)
				continue
				
			var res = res_eval(refs[i])
			if (instance_exists(res) && res.object_index = obj_resource)
				res.count++
		}
	}
	
	// Count template and resource references held by timelines
	with (obj_timeline)
	{
		if (temp != null && instance_exists(temp) && temp.object_index = obj_template && part_of = null)
			temp.count++

		var refs = array(
			glint_tex
		);
		
		if (type = e_tl_type.BLOCK && part_of = null && !has_temp)
		{
			array_add(refs, block_tex)
			if (app.project_render_material_maps)
			{
				array_add(refs, block_tex_material)
				array_add(refs, block_tex_normal)
			}
		}
		else if (type = e_tl_type.SPECIAL_BLOCK && part_of = null && !has_temp)
		{
			array_add(refs, model_tex)
			if (app.project_render_material_maps)
			{
				array_add(refs, model_tex_material)
				array_add(refs, model_tex_normal)
			}
		}

		for (var i = 0; i < array_length(refs); i++)
		{
			if (refs[i] = null)
				continue
				
			var res = res_eval(refs[i])
			if (instance_exists(res) && res.object_index = obj_resource)
				res.count++
		}
	}
	
	// Count resources used by keyframes
	with (obj_keyframe)
	{
		var refs = array(
			value[e_value.TEXTURE_OBJ],
			value[e_value.SOUND_OBJ],
			value[e_value.TEXT_FONT]
		);
		
		if (app.project_render_material_maps)
		{
			array_add(refs, value[e_value.TEXTURE_MATERIAL_OBJ])
			array_add(refs, value[e_value.TEXTURE_NORMAL_OBJ])
		}
		
		for (var i = 0; i < array_length(refs); i++)
		{
			if (refs[i] = null)
				continue
				
			var res = res_eval(refs[i])
			if (instance_exists(res) && res.object_index = obj_resource)
				res.count++
		}
	}

	// Count background resources
	with (app)
	{
		var refs = array(
			background_image,
			background_sky_sun_tex,
			background_sky_moon_tex,
			background_sky_clouds_tex,
			background_ground_tex
		);
		
		if (app.project_render_material_maps)
		{
			array_add(refs, background_ground_tex_material)
			array_add(refs, background_ground_tex_normal)
		}
		
		for (var i = 0; i < array_length(refs); i++)
		{
			if (refs[i] = null)
				continue
			
			var res = res_eval(refs[i])
			if (instance_exists(res) && res.object_index = obj_resource)
				res.count++
		}
	}
	
	// Project pack
	res_eval(project_pack_res).count = -1
	
	debug_timer_stop("update counts")
}
