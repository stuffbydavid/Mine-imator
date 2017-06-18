/// vertex_add_triangle(x1, y1, z1, x2, y2, z2, x3, y3, z3, tx1, ty1, tx2, ty2, tx3, ty3)

var x1, y1, z1, x2, y2, z2, x3, y3, z3;
var nx, ny, nz;

x1 = argument0
y1 = argument1
z1 = argument2
x2 = argument3
y2 = argument4
z2 = argument5
x3 = argument6
y3 = argument7
z3 = argument8

nx = (z1 - z2) * (y3 - y2) - (y1 - y2) * (z3 - z2)
ny = (x1 - x2) * (z3 - z2) - (z1 - z2) * (x3 - x2)
nz = (y1 - y2) * (x3 - x2) - (x1 - x2) * (y3 - y2)

vertex_add(x1, y1, z1, nx, ny, nz, argument9, argument10)
vertex_add(x2, y2, z2, nx, ny, nz, argument11, argument12)
vertex_add(x3, y3, z3, nx, ny, nz, argument13, argument14)
