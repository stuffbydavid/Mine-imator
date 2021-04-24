/// matrix_inverse(matrix)
/// @arg matrix

function matrix_inverse(mat)
{
	var inv;
	
	inv[0] = mat[5]  * mat[10] * mat[15] - 
			 mat[5]  * mat[11] * mat[14] - 
			 mat[9]  * mat[6]  * mat[15] + 
			 mat[9]  * mat[7]  * mat[14] +
			 mat[13] * mat[6]  * mat[11] - 
			 mat[13] * mat[7]  * mat[10];
	
	inv[4] = -mat[4]  * mat[10] * mat[15] + 
			  mat[4]  * mat[11] * mat[14] + 
			  mat[8]  * mat[6]  * mat[15] - 
			  mat[8]  * mat[7]  * mat[14] - 
			  mat[12] * mat[6]  * mat[11] + 
			  mat[12] * mat[7]  * mat[10];
	
	inv[8] = mat[4]  * mat[9] * mat[15] - 
			 mat[4]  * mat[11] * mat[13] - 
			 mat[8]  * mat[5] * mat[15] + 
			 mat[8]  * mat[7] * mat[13] + 
			 mat[12] * mat[5] * mat[11] - 
			 mat[12] * mat[7] * mat[9];
	
	inv[12] = -mat[4]  * mat[9] * mat[14] + 
			   mat[4]  * mat[10] * mat[13] +
			   mat[8]  * mat[5] * mat[14] - 
			   mat[8]  * mat[6] * mat[13] - 
			   mat[12] * mat[5] * mat[10] + 
			   mat[12] * mat[6] * mat[9];
	
	inv[1] = -mat[1]  * mat[10] * mat[15] + 
			  mat[1]  * mat[11] * mat[14] + 
			  mat[9]  * mat[2] * mat[15] - 
			  mat[9]  * mat[3] * mat[14] - 
			  mat[13] * mat[2] * mat[11] + 
			  mat[13] * mat[3] * mat[10];
	
	inv[5] = mat[0]  * mat[10] * mat[15] - 
			 mat[0]  * mat[11] * mat[14] - 
			 mat[8]  * mat[2] * mat[15] + 
			 mat[8]  * mat[3] * mat[14] + 
			 mat[12] * mat[2] * mat[11] - 
			 mat[12] * mat[3] * mat[10];
	
	inv[9] = -mat[0]  * mat[9] * mat[15] + 
			  mat[0]  * mat[11] * mat[13] + 
			  mat[8]  * mat[1] * mat[15] - 
			  mat[8]  * mat[3] * mat[13] - 
			  mat[12] * mat[1] * mat[11] + 
			  mat[12] * mat[3] * mat[9];
	
	inv[13] = mat[0]  * mat[9] * mat[14] - 
			  mat[0]  * mat[10] * mat[13] - 
			  mat[8]  * mat[1] * mat[14] + 
			  mat[8]  * mat[2] * mat[13] + 
			  mat[12] * mat[1] * mat[10] - 
			  mat[12] * mat[2] * mat[9];
	
	inv[2] = mat[1]  * mat[6] * mat[15] - 
			 mat[1]  * mat[7] * mat[14] - 
			 mat[5]  * mat[2] * mat[15] + 
			 mat[5]  * mat[3] * mat[14] + 
			 mat[13] * mat[2] * mat[7] - 
			 mat[13] * mat[3] * mat[6];
	
	inv[6] = -mat[0]  * mat[6] * mat[15] + 
			  mat[0]  * mat[7] * mat[14] + 
			  mat[4]  * mat[2] * mat[15] - 
			  mat[4]  * mat[3] * mat[14] - 
			  mat[12] * mat[2] * mat[7] + 
			  mat[12] * mat[3] * mat[6];
	
	inv[10] = mat[0]  * mat[5] * mat[15] - 
			  mat[0]  * mat[7] * mat[13] - 
			  mat[4]  * mat[1] * mat[15] + 
			  mat[4]  * mat[3] * mat[13] + 
			  mat[12] * mat[1] * mat[7] - 
			  mat[12] * mat[3] * mat[5];
	
	inv[14] = -mat[0]  * mat[5] * mat[14] + 
			   mat[0]  * mat[6] * mat[13] + 
			   mat[4]  * mat[1] * mat[14] - 
			   mat[4]  * mat[2] * mat[13] - 
			   mat[12] * mat[1] * mat[6] + 
			   mat[12] * mat[2] * mat[5];
	
	inv[3] = -mat[1] * mat[6] * mat[11] + 
			  mat[1] * mat[7] * mat[10] + 
			  mat[5] * mat[2] * mat[11] - 
			  mat[5] * mat[3] * mat[10] - 
			  mat[9] * mat[2] * mat[7] + 
			  mat[9] * mat[3] * mat[6];
	
	inv[7] = mat[0] * mat[6] * mat[11] - 
			 mat[0] * mat[7] * mat[10] - 
			 mat[4] * mat[2] * mat[11] +  
			 mat[4] * mat[3] * mat[10] + 
			 mat[8] * mat[2] * mat[7] - 
			 mat[8] * mat[3] * mat[6];
	
	inv[11] = -mat[0] * mat[5] * mat[11] + 
			   mat[0] * mat[7] * mat[9] + 
			   mat[4] * mat[1] * mat[11] - 
			   mat[4] * mat[3] * mat[9] - 
			   mat[8] * mat[1] * mat[7] + 
			   mat[8] * mat[3] * mat[5];
	
	inv[15] = mat[0] * mat[5] * mat[10] - 
			  mat[0] * mat[6] * mat[9] - 
			  mat[4] * mat[1] * mat[10] + 
			  mat[4] * mat[2] * mat[9] + 
			  mat[8] * mat[1] * mat[6] - 
			  mat[8] * mat[2] * mat[5];
	
	var det = mat[0] * inv[0] + mat[1] * inv[4] + mat[2] * inv[8] + mat[3] * inv[12];
	var inv_det = 1.0 / det;
	
	for (var i = 0; i < 16; i++)
		inv[i] *= inv_det;
	
	return inv;
}
