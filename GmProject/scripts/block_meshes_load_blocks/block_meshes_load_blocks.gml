/// @desc Save decoded builder blocks, optionally leaving existing geometry unchanged.

function block_meshes_load_blocks(blocksonly = false)
{
	var size, meshnum, count;
	size = mc_builder.build_size
	meshnum = vec3(
		ceil(size[X] / block_mesh_size),
		ceil(size[Y] / block_mesh_size),
		ceil(size[Z] / block_mesh_size)
	)
	count = meshnum[X] * meshnum[Y] * meshnum[Z]
	
	debug_timer_start()

	// A changed source must be reloaded normally before it can match the cached mesh
	if (blocksonly && array_length(block_meshes) > 0)
	{
		if (scenery_size[X] != size[Y] || scenery_size[Y] != size[X] || scenery_size[Z] != size[Z])
		{
			log("Schematic error", "Source dimensions no longer match the loaded mesh")
			return false
		}
	}
	else
	{
		block_meshes_destroy()
		block_meshes = array_create(count, null)

		if (blocksonly)
			scenery_size = vec3(size[Y], size[X], size[Z])
	}

	block_meshes_size = meshnum

	for (var s = 0; s < count; s++)
	{
		var mesh, start, active;
		mesh = block_meshes[s]
		if (mesh = null)
		{
			mesh = new_obj(obj_block_mesh)
			block_meshes[@s] = mesh
		}

		start = vec3(
			(s mod meshnum[X]) * block_mesh_size,
			((s div meshnum[X]) mod meshnum[Y]) * block_mesh_size,
			(s div (meshnum[X] * meshnum[Y])) * block_mesh_size
		)

		with (mesh)
		{
			block_grid_size = vec3(
				min(block_mesh_size, size[X] - start[X]),
				min(block_mesh_size, size[Y] - start[Y]),
				min(block_mesh_size, size[Z] - start[Z])
			)
			active = block_mesh_load_blocks(start)
		}

		if (!active && array_length(mesh.block_vbuffer_render_order) = 0)
		{
			with (mesh)
				instance_destroy()

			block_meshes[@s] = null
		}
	}
	
	debug_timer_stop("block_meshes_load_blocks")

	return true
}
