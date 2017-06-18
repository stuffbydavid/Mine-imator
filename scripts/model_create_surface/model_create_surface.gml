/// model_create_surface(radius, tx1, ty1, tx2, ty2, invert)

var rad, tx1, ty1, tx2, ty2, invert;
rad = argument0
tx1 = argument1
ty1 = argument2
tx2 = argument3
ty2 = argument4
invert = argument5

model_start()

if (invert) {
    vertex_add_triangle(rad, 0, rad, -rad, 0, rad, rad, 0, -rad, tx2, ty1, tx1, ty1, tx2, ty2)
    vertex_add_triangle(-rad, 0, rad, -rad, 0, -rad, rad, 0, -rad, tx1, ty1, tx1, ty2, tx2, ty2)
} else {
    vertex_add_triangle(-rad, 0, rad, rad, 0, rad, rad, 0, -rad, tx1, ty1, tx2, ty1, tx2, ty2)
    vertex_add_triangle(-rad, 0, -rad, -rad, 0, rad, rad, 0, -rad, tx1, ty2, tx1, ty1, tx2, ty2)
}

return model_done()
