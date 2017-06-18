/// model_create_cube(radius, tx1, ty1, tx2, ty2, thflip, tvflip, invert, mapped)

var rad, tx1, ty1, tx2, ty2, thflip, tvflip, invert, mapped;
var txs, tys;
rad = argument0
tx1 = argument1
ty1 = argument2
tx2 = argument3
ty2 = argument4
thflip = argument5
tvflip = argument6
invert = argument7
mapped = argument8

model_start()

txs = 1/3
tys = 1/2

// X+
if (mapped) {
    if (invert)
        tx1 = txs
    else
        tx1 = txs * 2
    ty1 = 0
    tx2 = tx1 + txs
    ty2 = ty1 + tys
    if (thflip < 0) {
        var tmp = tx1;
        tx1 = tx2
        tx2 = tmp
    }
    if (tvflip < 0) {
        var tmp = ty1;
        ty1 = ty2
        ty2 = tmp
    }
}

if (invert) {
    vertex_add_triangle(rad, rad, rad, rad, rad, -rad, rad, -rad, rad, tx1, ty1, tx1, ty2, tx2, ty1)
    vertex_add_triangle(rad, -rad, rad, rad, rad, -rad, rad, -rad, -rad, tx2, ty1, tx1, ty2, tx2, ty2)
} else {
    vertex_add_triangle(rad, rad, -rad, rad, rad, rad, rad, -rad, rad, tx1, ty2, tx1, ty1, tx2, ty1)
    vertex_add_triangle(rad, rad, -rad, rad, -rad, rad, rad, -rad, -rad, tx1, ty2, tx2, ty1, tx2, ty2)
}

// X-
if (mapped) {
    if (invert)
        tx1 = txs * 2
    else
        tx1 = txs
    ty1 = 0
    tx2 = tx1 + txs
    ty2 = ty1 + tys
    if (thflip < 0) {
        var tmp = tx1;
        tx1 = tx2
        tx2 = tmp
    }
    if (tvflip < 0) {
        var tmp = ty1;
        ty1 = ty2
        ty2 = tmp
    }
}

if (invert) {
    vertex_add_triangle(-rad, rad, -rad, -rad, rad, rad, -rad, -rad, rad, tx2, ty2, tx2, ty1, tx1, ty1)
    vertex_add_triangle(-rad, rad, -rad, -rad, -rad, rad, -rad, -rad, -rad, tx2, ty2, tx1, ty1, tx1, ty2)
} else {
    vertex_add_triangle(-rad, rad, rad, -rad, rad, -rad, -rad, -rad, rad, tx2, ty1, tx2, ty2, tx1, ty1)
    vertex_add_triangle(-rad, -rad, rad, -rad, rad, -rad, -rad, -rad, -rad, tx1, ty1, tx2, ty2, tx1, ty2)
}

// Y+
if (mapped) {
    tx1 = 0
    ty1 = 0
    tx2 = tx1 + txs
    ty2 = ty1 + tys
    if (thflip < 0) {
        var tmp = tx1;
        tx1 = tx2
        tx2 = tmp
    }
    if (tvflip < 0) {
        var tmp = ty1;
        ty1 = ty2
        ty2 = tmp
    }
}

if (invert) {
    vertex_add_triangle(rad, rad, rad, -rad, rad, rad, rad, rad, -rad, tx2, ty1, tx1, ty1, tx2, ty2)
    vertex_add_triangle(-rad, rad, rad, -rad, rad, -rad, rad, rad, -rad, tx1, ty1, tx1, ty2, tx2, ty2)
} else {
    vertex_add_triangle(-rad, rad, rad, rad, rad, rad, rad, rad, -rad, tx1, ty1, tx2, ty1, tx2, ty2)
    vertex_add_triangle(-rad, rad, -rad, -rad, rad, rad, rad, rad, -rad, tx1, ty2, tx1, ty1, tx2, ty2)
}

// Y-
if (mapped) {
    tx1 = 0
    ty1 = tys
    tx2 = tx1 + txs
    ty2 = ty1 + tys
    if (thflip < 0) {
        var tmp = tx1;
        tx1 = tx2
        tx2 = tmp
    }
    if (tvflip < 0) {
        var tmp = ty1;
        ty1 = ty2
        ty2 = tmp
    }
}

if (invert) {
    vertex_add_triangle(-rad, -rad, rad, rad, -rad, rad, rad, -rad, -rad, tx2, ty1, tx1, ty1, tx1, ty2)
    vertex_add_triangle(-rad, -rad, -rad, -rad, -rad, rad, rad, -rad, -rad, tx2, ty2, tx2, ty1, tx1, ty2)
} else {
    vertex_add_triangle(rad, -rad, rad, -rad, -rad, rad, rad, -rad, -rad, tx1, ty1, tx2, ty1, tx1, ty2)
    vertex_add_triangle(-rad, -rad, rad, -rad, -rad, -rad, rad, -rad, -rad, tx2, ty1, tx2, ty2, tx1, ty2)
}

// Z+
if (mapped) {
    tx1 = txs
    ty1 = tys
    tx2 = tx1 + txs
    ty2 = ty1 + tys
    if (thflip < 0) {
        var tmp = tx1;
        tx1 = tx2
        tx2 = tmp
    }
    if (tvflip < 0) {
        var tmp = ty1;
        ty1 = ty2
        ty2 = tmp
    }
}

if (invert) {
    vertex_add_triangle(rad, -rad, rad, -rad, -rad, rad, -rad, rad, rad, tx2, ty1, tx1, ty1, tx1, ty2)
    vertex_add_triangle(rad, rad, rad, rad, -rad, rad, -rad, rad, rad, tx2, ty2, tx2, ty1, tx1, ty2)
} else {
    vertex_add_triangle(-rad, -rad, rad, rad, -rad, rad, -rad, rad, rad, tx1, ty1, tx2, ty1, tx1, ty2)
    vertex_add_triangle(rad, -rad, rad, rad, rad, rad, -rad, rad, rad, tx2, ty1, tx2, ty2, tx1, ty2)
}

// Z-
if (mapped) {
    tx1 = txs * 2
    ty1 = tys
    tx2 = tx1 + txs
    ty2 = ty1 + tys
    if (thflip < 0) {
        var tmp = tx1;
        tx1 = tx2
        tx2 = tmp
    }
    if (tvflip < 0) {
        var tmp = ty1;
        ty1 = ty2
        ty2 = tmp
    }
}

if (invert) {
    vertex_add_triangle(-rad, -rad, -rad, rad, -rad, -rad, -rad, rad, -rad, tx1, ty2, tx2, ty2, tx1, ty1)
    vertex_add_triangle(rad, -rad, -rad, rad, rad, -rad, -rad, rad, -rad, tx2, ty2, tx2, ty1, tx1, ty1)
} else {
    vertex_add_triangle(rad, -rad, -rad, -rad, -rad, -rad, -rad, rad, -rad, tx2, ty2, tx1, ty2, tx1, ty1)
    vertex_add_triangle(rad, rad, -rad, rad, -rad, -rad, -rad, rad, -rad, tx2, ty1, tx2, ty2, tx1, ty1)
}

return model_done()
