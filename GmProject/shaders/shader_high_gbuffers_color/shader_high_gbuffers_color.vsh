/// CppOnly #define CPP_SUN_GBUFFERS 1

#pragma shady: inline(common_gbuffers.GBUFFERS_LIB)

void main()
{
	#pragma shady: inline(common_gbuffers.GBUFFERS_VERTEX_LIB)
}
