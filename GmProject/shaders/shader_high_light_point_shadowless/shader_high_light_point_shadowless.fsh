#define PI 3.14159265

uniform sampler2D uTexture; // static

uniform int uIsSky;
uniform int uLightAmount; // static
uniform vec4 uLightData[128]; // static
uniform int uIsWater;
uniform vec3 uCameraPosition; // static
uniform float uLightSpecular;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec4 vColor;
varying vec2 vTexCoord;
varying vec4 vCustom;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_material.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_material.SPECULAR_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	vec3 lightResult = vec3(0.0);
	vec3 specResult = vec3(0.0);
	
	if (uIsSky > 0)
	{
		lightResult = vec3(1.0);
		specResult = vec3(uLightSpecular);
	}
	else
	{
		// Get material data
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		vec3 normal = getMappedNormal(vTexCoord, getTBN(vNormal, vTangent));
		
		for (int i = 0; i < uLightAmount; i++)
		{
			vec4 data1 = uLightData[i * 3];
			vec4 data2 = uLightData[i * 3 + 1];
			vec4 data3 = uLightData[i * 3 + 2];
			vec3 lightPosition = data1.xyz;
			float lightRange = data1.w;
			float lightFadeSize = data2.w;
			
			// No use in shading a pixel if it's not in range
			if (distance(vPosition, lightPosition) > lightRange)
				continue;
			
			// Diffuse factor
			float dif = max(0.0, dot(normal, normalize(lightPosition - vPosition)));
			
			// Attenuation factor
			float att = 1.0 - clamp((distance(vPosition, lightPosition) - lightRange * (1.0 - lightFadeSize)) / (lightRange * lightFadeSize), 0.0, 1.0);
			dif *= att;
			
			vec3 light = vec3(0.0);
			vec3 spec = vec3(0.0);
			
			// Diffuse light
			light = data2.rgb * data3.r * dif;
			
			lightResult.rgb += light;
			
			// Calculate specular
			float specular = getSpecular(normal, normalize(lightPosition - vPosition), uCameraPosition, vPosition, F0, roughness, metallic);
			
			spec = data2.rgb * specular * mix(vec3(1.0), baseColor.rgb * vColor.rgb, metallic) * data3.g * uLightSpecular * dif;
			specResult.rgb += spec;
		}
	}
	
	gl_FragData[0] = vec4(lightResult, baseColor.a);
	gl_FragData[1] = vec4(specResult, baseColor.a);
	
	if (baseColor.a == 0.0)
		discard;
}
