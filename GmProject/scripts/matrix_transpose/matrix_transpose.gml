/// CppSeparate MatrixType matrix_transpose(MatrixType)
/// @arg matrix

function matrix_transpose(mat)
{
	var trmat;
	
	for (var i = 0; i < 4; i++)
		for (var j = 0; j < 4; j++)
			trmat[i * 4 + j] = mat[j * 4 + i]
	
	return trmat
}
