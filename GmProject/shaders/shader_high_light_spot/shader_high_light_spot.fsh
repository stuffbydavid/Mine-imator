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
uniform float uShadowRadius; // static
uniform vec3 uShadowPosition; // static
uniform float uLightSpecular;

uniform sampler2D uDepthBuffer; // static
uniform int uShadowBlurQuality; // static
uniform vec2 uPCSSKernel[64]; // static
uniform vec2 uScreenSize; // static

uniform vec3 uSSSRadius;

uniform vec3 uCameraPosition; // static
uniform float uGamma;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying vec4 vShadowCoord;
varying vec4 vCustom;
varying vec4 vColor;
varying vec4 vClipPosition;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_material.SPECULAR_LIB)
#pragma shady: inline(common_material.SSS_TRANSLUCENCY_LIB)
#pragma shady: inline(common_shadows.PCSS_LIB)

float getSpotDepth(vec2 coord)
{
	return uLightNear + texture2D(uDepthBuffer, coord).r * (uLightFar - uLightNear);
}

float getSpotShadow(vec2 coord, float fragDepth, vec2 receiverDepthGradient, float bias, out float centerDepth)
{
	centerDepth = getSpotDepth(coord);
	
	int quality = uShadowBlurQuality;
	if (quality > PCSS_MAX_SAMPLES)
		quality = PCSS_MAX_SAMPLES;
	
	if (quality <= 0 || uShadowRadius <= 0.0)
		return getPCSSVisibility(fragDepth, centerDepth, bias);
	
	vec2 rotation = getPCSSPixelRotation(vClipPosition, uScreenSize);
	int blockerSamples = getPCSSBlockerSamples(quality);
	float searchRadius = min(uShadowRadius / max(fragDepth, uLightNear), 64.0 / PCSS_REFERENCE_SHADOW_SIZE);
	float blockerDepth = 0.0;
	float blockers = 0.0;
	
	// Blocker search
	for (int blockerIndex = 0; blockerIndex < PCSS_MAX_BLOCKER_SAMPLES; blockerIndex++)
	{
		if (blockerIndex >= blockerSamples)
			break;
		
		vec2 sampleCoord = clamp(coord + getPCSSSampleOffset(blockerIndex, rotation) * searchRadius, vec2(0.0), vec2(1.0));
		float sampleDepth = getSpotDepth(sampleCoord);
		float receiverDepth = getPCSSReceiverDepth(coord, fragDepth, sampleCoord, receiverDepthGradient);
		if (isPCSSBlocker(receiverDepth, sampleDepth, bias))
		{
			blockerDepth += sampleDepth;
			blockers += 1.0;
		}
	}
	
	if (blockers == 0.0)
		return 1.0;
	
	blockerDepth /= blockers;
	
	// Get penumbra for filter
	float penumbra = uShadowRadius * max(fragDepth - blockerDepth - bias, 0.0) / max(blockerDepth, uLightNear); // Ignore the bias gap
	float filterRadius = min(penumbra / max(fragDepth, uLightNear), 64.0 / PCSS_REFERENCE_SHADOW_SIZE);
	float visibility = 0.0;
	
	// Filter shadow
	for (int filterIndex = 0; filterIndex < PCSS_MAX_SAMPLES; filterIndex++)
	{
		if (filterIndex >= quality)
			break;
		
		vec2 sampleCoord = clamp(coord + getPCSSSampleOffset(filterIndex, rotation) * filterRadius, vec2(0.0), vec2(1.0));
		float sampleDepth = getSpotDepth(sampleCoord);
		float receiverDepth = getPCSSReceiverDepth(coord, fragDepth, sampleCoord, receiverDepthGradient);
		visibility += getPCSSVisibility(receiverDepth, sampleDepth, bias);
	}
	
	return visibility / float(quality);
}

void main() 
{
	vec3 light = vec3(0.0);
	vec3 spec = vec3(0.0);
	
	vec2 tex = vTexCoord;
	vec4 baseColor = texture2D(uTexture, tex) * vColor;
	vec3 lightCol = uLightColor.rgb * uLightStrength;
	float shadowFragDepth = min(vShadowCoord.z, uLightFar);
	vec2 shadowFragCoord = (vec2(vShadowCoord.x, -vShadowCoord.y) / max(vShadowCoord.z, 0.0001) + 1.0) * 0.5;
	vec2 receiverDepthGradient = getPCSSReceiverDepthGradient(shadowFragCoord, shadowFragDepth);
	
	handleAlphaDiscard(vPosition, baseColor);
	
	if (uIsSky == 0)
	{
		// Get material data
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		vec3 normal = getMappedNormal(vTexCoord, getTBN(vNormal, vTangent));
		vec3 lightDir = normalize(uLightPosition - vPosition);
		vec3 baseColorLinear = pow(baseColor.rgb, vec3(uGamma));
		vec3 specularF0 = mix(vec3(F0), baseColorLinear, metallic);
		vec3 F = getDirectFresnel(normal, lightDir, uCameraPosition, vPosition, specularF0);
		
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
				fragDepth = shadowFragDepth;
				fragCoord = shadowFragCoord;
				
				if (difMask > 0.0)
				{
					// Calculate bias
					float bias = 1.0;
					
					// Shadow
					float sampleDepth;
					shadow = getSpotShadow(fragCoord, fragDepth, receiverDepthGradient, bias, sampleDepth);
					
					// Subsurface translucency
					if (sss > 0.0 && dif == 0.0)
						subsurf = getSubsurfaceTranslucency(fragDepth, sampleDepth, uSSSRadius * sss) * att;
				}
			}
		}
		
		// Diffuse light
		light = lightCol * dif * shadow;
		
		// Subsurface highlight
		if (sss > 0.0)
			handleSubsurfaceHighlight(light, subsurf, normal, lightDir, lightCol, uCameraPosition, vPosition, sss, difMask);
		
		light *= (vec3(1.0) - F) * (1.0 - metallic);
		
		// Calculate specular
		if (uLightSpecular * dif * shadow > 0.0)
		{
			vec3 specular = getSpecular(normal, lightDir, uCameraPosition, vPosition, specularF0, roughness);
			spec = uLightColor.rgb * shadow * uLightSpecular * dif * specular;
		}
	}
	
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
}
