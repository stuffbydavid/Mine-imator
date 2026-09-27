/// CppSeparate void builder_add_face(Scope<obj_builder_thread>, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, RealType, VarType)
function builder_add_face()
{
	builder_add_triangle(
		argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], 
		argument[12], argument[13], argument[14], argument[15], argument[16], argument[17],
		argument[20]
	)
	builder_add_triangle(
		argument[6], argument[7], argument[8], argument[9], argument[10], argument[11], argument[0], argument[1], argument[2], 
		argument[16], argument[17], argument[18], argument[19], argument[12], argument[13],
		argument[20]
	)
}