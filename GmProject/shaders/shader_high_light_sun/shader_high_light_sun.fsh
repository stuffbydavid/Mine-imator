uniform sampler2D uTexture; // static
uniform int uIsSky;
uniform vec3 uCameraPosition; // static
uniform float uGamma;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec2 vTexCoord;
varying vec4 vCustom;
varying vec4 vColor;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_sun.SUN_LIB)

void main()
{
	vec4 baseColor = texture2D(uTexture, vTexCoord) * vColor;
	
	handleAlphaDiscard(vPosition, baseColor);
	
	float roughness, metallic, emissive, F0, sss;
	vec3 normal = vec3(0.0);
	
	roughness = metallic = F0 = sss = 0.0;
	
	if (uIsSky == 0)
	{
		getMaterial(roughness, metallic, emissive, F0, sss);
		normal = getMaterialNormal(vTexCoord, vPosition, getTBN(vNormal, vTangent));
	}
	
	vec3 light, spec;
	getSunLighting(baseColor, normal, roughness, metallic, F0, sss, light, spec);
	
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
}
