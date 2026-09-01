uniform sampler2D uTexture; // static
uniform int uIsSky;
uniform int uIsWater;

uniform vec3 uLightPosition; // static
uniform vec4 uLightColor; // static
uniform float uLightStrength; // static
uniform float uLightNear; // static
uniform float uLightFar; // static
uniform float uLightFadeSize; // static
uniform float uLightSpotSharpness; // static
uniform vec3 uShadowPosition; // static
uniform float uLightSpecular;

uniform sampler2D uDepthBuffer; // static

uniform vec3 uSSSRadius;

uniform vec3 uCameraPosition; // static

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying vec4 vShadowCoord;
varying vec4 vCustom;
varying vec4 vColor;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_material.SPECULAR_LIB)
#pragma shady: inline(common_material.SSS_TRANSLUCENCY_LIB)

void main() 
{
	vec3 light = vec3(0.0);
	vec3 spec = vec3(0.0);
	
	vec2 tex = vTexCoord;
	vec4 baseColor = texture2D(uTexture, tex) * vColor;
	vec3 lightCol = uLightColor.rgb * uLightStrength;
	
	handleAlphaDiscard(vPosition, baseColor);
	
	if (uIsSky == 0)
	{
		// Get material data
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		vec3 normal = getMappedNormal(vTexCoord, getTBN(vNormal, vTangent));
		vec3 lightDir = normalize(uLightPosition - vPosition);
		
		float dif = 0.0;
		float difMask = 0.0;
		float shadow = 1.0;
		float att = 0.0;
		vec3 subsurf = vec3(0.0);
		
		// Check if not behind the spot light
		if (vScreenCoord.w > 0.0)
		{
			// Diffuse factor
			dif = max(0.0, dot(normal, lightDir));
			
			// Attenuation factor
			att = 1.0 - clamp((distance(vPosition, uLightPosition) - uLightFar * (1.0 - uLightFadeSize)) / (uLightFar * uLightFadeSize), 0.0, 1.0);
			dif *= att;
			
			if (dif > 0.0 || sss > 0.0)
			{
				// Spotlight circle
				float fragDepth = min(vScreenCoord.z, uLightFar);
				vec2 fragCoord = (vec2(vScreenCoord.x, -vScreenCoord.y) / vScreenCoord.z + 1.0) * 0.5;
				
				// Texture position must be valid
				if (fragCoord.x > 0.0 && fragCoord.y > 0.0 && fragCoord.x < 1.0 && fragCoord.y < 1.0)
				{
					// Create circle
					difMask = 1.0 - clamp((distance(fragCoord, vec2(0.5, 0.5)) - 0.5 * uLightSpotSharpness) / (0.5 * max(0.01, 1.0 - uLightSpotSharpness)), 0.0, 1.0);
				} 
				else
					difMask = 0.0;
				
				dif *= difMask;
				
				// Calculate shadow
				fragDepth = min(vShadowCoord.z, uLightFar);
				fragCoord = (vec2(vShadowCoord.x, -vShadowCoord.y) / vShadowCoord.z + 1.0) * 0.5;
				
				if (difMask > 0.0)
				{
					// Calculate bias
					float bias = 1.0;
					
					// Shadow
					float sampleDepth = uLightNear + texture2D(uDepthBuffer, fragCoord).r * (uLightFar - uLightNear);
					shadow = ((fragDepth - bias) > sampleDepth) ? 0.0 : 1.0;
					
					// Subsurface translucency
					if (sss > 0.0 && dif == 0.0)
						subsurf = getSubsurfaceTranslucency(fragDepth, sampleDepth, bias, lightCol, uSSSRadius * sss) * att;
				}
			}
		}
		
		// Diffuse light
		light = lightCol * dif * shadow;
		
		// Subsurface highlight
		if (sss > 0.0)
			handleSubsurfaceHighlight(light, subsurf, normal, lightDir, lightCol, uCameraPosition, vPosition, sss, difMask);
		
		// Calculate specular
		if (uLightSpecular * dif * shadow > 0.0)
		{
			float specular = getSpecular(normal, lightDir, uCameraPosition, vPosition, F0, roughness, metallic);
		
			spec = uLightColor.rgb * shadow * difMask * uLightSpecular * dif * (specular * mix(vec3(1.0), baseColor.rgb, metallic));
		}
	}
	
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
}
