/// draw_world_item(vbuffer, bounce, facecamera, resource)
/// @arg vbuffer
/// @arg bounce
/// @arg facecamera
/// @arg resource

var vbuffer, bounce, facecamera, res;
var rot, off;
vbuffer = argument0
bounce = argument1
facecamera = argument2
res = argument3

if (!res.ready)
    res = res_def

rot = vec3(0)
off = point3D(0, 0, 0)

if (bounce)
{
    var d, t;
    d = 60 * 2
    t = current_step mod d * 2
    if (t < d)
        off[Z] = ease("easeinoutquad", t / d) * 2 - 1
    else
        off[Z] = 1 - ease("easeinoutquad", (t - d) / d) * 2
}

if (facecamera)
{
    var pos = point3D_mul_matrix(point3D(0, 0, 0), matrix_get(matrix_world));
    rot[Z] = 90 + point_direction(pos[X], pos[Y], proj_from[X], proj_from[Y])
}

matrix_world_multiply_pre(matrix_create(point3D(0, 0, 0), rot, vec3(1)))
matrix_add_offset()
matrix_world_multiply_post(matrix_create(off, vec3(0), vec3(1)))

shader_texture = res.item_texture
shader_use()
vbuffer_render(vbuffer)
