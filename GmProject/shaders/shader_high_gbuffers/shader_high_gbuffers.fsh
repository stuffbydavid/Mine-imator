#pragma shady: inline(common_gbuffers.GBUFFERS_LIB)

void main()
{
	vec4 baseColor, depth, normal, material, glint;
	vec3 normalWorld;
	float roughness, metallic, F0, sss;
	
	getGbuffers(baseColor, normalWorld, roughness, metallic, F0, sss, depth, normal, material, glint);
	
	gl_FragData[0] = depth;
	gl_FragData[1] = normal;
	gl_FragData[2] = material;
	gl_FragData[3] = glint;
}
