/// matrix_transpose(matrix)
/// @matrix

var mat, trans;
mat = argument0;

for (var i = 0; i < 4; i++)
    for (var j = 0; j < 4; j++)
        trans[i * 4 + j] = mat[j * 4 + i];
        
return trans
