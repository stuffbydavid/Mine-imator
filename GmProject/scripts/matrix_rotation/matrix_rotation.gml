/// matrix_rotation(matrix)
/// @arg matrix

function matrix_rotation(mat)
{
    var rx, ry, rz;
    
    rx = -arcsin(clamp(mat[6], -1, 1))
    var cx = cos(rx);
    
    if (abs(cx) > 0.000001)
    {
        ry = arctan2(mat[2], mat[10])
        rz = arctan2(mat[4], mat[5])
    }
    else // Gimbal lock
    {
        ry = arctan2(-mat[8], mat[0])
        rz = 0
    }
    
    return [rx, ry, rz]
}
