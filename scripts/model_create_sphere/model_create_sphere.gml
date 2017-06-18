/// model_create_sphere(rad, tx1, ty1, tx2, ty2, detail, invert)

var rad, tx1, ty1, tx2, ty2, detail, invert;
var i;
rad = argument0
tx1 = argument1
ty1 = argument2
tx2 = argument3
ty2 = argument4
detail = argument5
invert = argument6

model_start()

i = 0
tx1 += 0.25
tx2 += 0.25

while (i < 1) {
    var ip, j;
    ip = i
    i += 1/detail
    j = 0
    while (j < 1) {
        var jp;
        var n1x, n1y, n1z, n2x, n2y, n2z, n3x, n3y, n3z, n4x, n4y, n4z;
        var x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4;
        var txs, tys, txm, tym, n;
        jp = j
        j += 1 / (detail - 2)
        txs = tx2 - tx1
        tys = ty2 - ty1
        txm = tx1 + txs / 2
        tym = ty1 + tys / 2
        n = test(invert, -1, 1)
        
        n1x = sin(ip * pi * 2) * sin(jp * pi)
        n1y = -cos(ip * pi * 2) * sin(jp * pi)
        n1z = -cos(jp * pi)
        n2x = sin(ip * pi * 2) * sin(j * pi)
        n2y = -cos(ip * pi * 2) * sin(j * pi)
        n2z = -cos(j * pi)
        n3x = sin(i * pi * 2) * sin(jp * pi)
        n3y = -cos(i * pi * 2) * sin(jp * pi)
        n3z = -cos(jp * pi)
        n4x = sin(i * pi * 2) * sin(j * pi)
        n4y = -cos(i * pi * 2) * sin(j * pi)
        n4z = -cos(j * pi)
        
        x1 = n1x * rad
        y1 = n1y * rad
        z1 = n1z * rad
        x2 = n2x * rad
        y2 = n2y * rad
        z2 = n2z * rad
        x3 = n3x * rad
        y3 = n3y * rad
        z3 = n3z * rad
        x4 = n4x * rad
        y4 = n4y * rad
        z4 = n4z * rad
        
        if (jp > 0) {
            if (invert) {
                vertex_add(x3, y3, z3, n3x * n, n3y * n, n3z * n, tx2 - i * txs, tym - n3z * (tys / 2))
                vertex_add(x1, y1, z1, n1x * n, n1y * n, n1z * n, tx2 - ip * txs, tym - n1z * (tys / 2))
                vertex_add(x4, y4, z4, n4x * n, n4y * n, n4z * n, tx2 - i * txs, tym - n4z * (tys / 2))
            } else {
                vertex_add(x1, y1, z1, n1x * n, n1y * n, n1z * n, tx2 - ip * txs, tym - n1z * (tys / 2))
                vertex_add(x3, y3, z3, n3x * n, n3y * n, n3z * n, tx2 - i * txs, tym - n3z * (tys / 2))
                vertex_add(x4, y4, z4, n4x * n, n4y * n, n4z * n, tx2 - i * txs, tym - n4z * (tys / 2))
            }
        }
        if (j < 1) {
            if (invert) {
                vertex_add(x4, y4, z4, n4x * n, n4y * n, n4z * n, tx2 - i * txs, tym - n4z * (tys / 2))
                vertex_add(x1, y1, z1, n1x * n, n1y * n, n1z * n, tx2 - ip * txs, tym - n1z * (tys / 2))
                vertex_add(x2, y2, z2, n2x * n, n2y * n, n2z * n, tx2 - ip * txs, tym - n2z * (tys / 2))
            } else {
                vertex_add(x1, y1, z1, n1x * n, n1y * n, n1z * n, tx2 - ip * txs, tym - n1z * (tys / 2))
                vertex_add(x4, y4, z4, n4x * n, n4y * n, n4z * n, tx2 - i * txs, tym - n4z * (tys / 2))
                vertex_add(x2, y2, z2, n2x * n, n2y * n, n2z * n, tx2 - ip * txs, tym - n2z * (tys / 2))
            }
        }
    }
}

return model_done()
