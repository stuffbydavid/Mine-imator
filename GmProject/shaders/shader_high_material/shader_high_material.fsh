uniform sampler2D uTexture; // static

uniform vec3 uCameraPosition; // static
uniform int uIsSky;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec4 vCustom;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_material.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_util.PACK_VALUE_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	handleAlphaDiscard(vPosition, baseColor);
	
	// Get material data
	float roughness, metallic, emissive, F0, sss;
	getMaterial(roughness, metallic, emissive, F0, sss);
	
	// Fresnel
	float F = getFresnel(getMappedNormal(vTexCoord, getTBN(vNormal, vTangent)), F0, roughness, uCameraPosition, vPosition);
	
	if (uIsSky > 0)
		F = 0.0;
	
	gl_FragData[0] = vec4(roughness, metallic, F, 1.0);
	
	// Emissive
	gl_FragData[1] = vec4(packValue((emissive / 255.0) * baseColor.a), baseColor.a);
}
