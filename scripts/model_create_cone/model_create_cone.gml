/// model_create_cone(radius, tx1, ty1, tx2, ty2, thflip, tvflip, detail, closed, invert, mapped)

var rad, tx1, ty1, tx2, ty2, thflip, tvflip, detail, closed, invert, mapped;
var i;
rad = argument0
tx1 = argument1
ty1 = argument2
tx2 = argument3
ty2 = argument4
thflip = argument5
tvflip = argument6
detail = argument7
closed = argument8
invert = argument9
mapped = argument10

model_start()

i = 0
tx1 += 0.25
tx2 += 0.25

while (i < 1) {
    var ip;
    var n1x, n1y, n2x, n2y;
    var x1, y1, x2, y2;
    var txs, tys, txm, tym;
    ip = i
    i += 1/detail
    txs = tx2 - tx1
    tys = ty2 - ty1
    txm = tx1 + txs / 2
    tym = ty1 + tys / 2
    
    n1x = cos(ip * pi * 2)
    n1y = -sin(ip * pi * 2)
    n2x = cos(i * pi * 2)
    n2y = -sin(i * pi * 2)
    x1 = n1x * rad
    y1 = n1y * rad
    x2 = n2x * rad
    y2 = n2y * rad
    
    // Invert normals
    if (invert) {
        n1x *= -1
        n1y *= -1
        n2x *= -1
        n2y *= -1
    }
    
    if (mapped) {
        txs = 1/2
        tys = 1
        txs *= thflip
        tys *= tvflip
        tym = tys / 2
    }
    
    if (closed) {
        if (mapped)
            txm = 3/4
            
        if (invert) // Bottom
            vertex_add_triangle(x1, y1, -rad, 0, 0, -rad, x2, y2, -rad, 
                            txm + cos(ip * pi * 2) * (txs / 2), tym + sin(ip * pi * 2) * (tys / 2), 
                            txm, tym, 
                            txm + cos(i * pi * 2) * (txs / 2), tym + sin(i * pi * 2) * (tys / 2))
        else
            vertex_add_triangle(0, 0, -rad, x1, y1, -rad, x2, y2, -rad, 
                            txm, tym, 
                            txm + cos(ip * pi * 2) * (txs / 2), tym + sin(ip * pi * 2) * (tys / 2), 
                            txm + cos(i * pi * 2) * (txs / 2), tym + sin(i * pi * 2) * (tys / 2))
    }
    
    // Sides
    if (mapped) {
        txm = 1/4
        tx1 = 0
        ty1 = 0
        tx2 = abs(txs)
        ty2 = abs(tys)
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
        vertex_add(x2, y2, -rad, n2x, n2y, 0, tx1 + txs * i, ty1 + tys)
        vertex_add(0, 0, rad, 0, 0, 1, tx1 + txs * i, ty1)
        vertex_add(x1, y1, -rad, n1x, n1y, 0, tx1 + txs * ip, ty1 + tys)
    } else {
        vertex_add(0, 0, rad, 0, 0, 1, tx1 + txs * i, ty1)
        vertex_add(x2, y2, -rad, n2x, n2y, 0, tx1 + txs * i, ty1 + tys)
        vertex_add(x1, y1, -rad, n1x, n1y, 0, tx1 + txs * ip, ty1 + tys)
    }
}

return model_done()
