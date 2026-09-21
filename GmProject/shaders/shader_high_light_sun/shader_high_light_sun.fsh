#define NUM_CASCADES 3

uniform sampler2D uTexture; // static
uniform int uIsSky;

uniform vec3 uLightDirection; // static
uniform vec4 uLightColor; // static
uniform float uLightStrength; // static
uniform float uSunNear[NUM_CASCADES]; // static
uniform float uSunFar[NUM_CASCADES]; // static
uniform float uCascadeWorldSize[NUM_CASCADES]; // static

uniform sampler2D uDepthBuffer0; // static
uniform sampler2D uDepthBuffer1; // static
uniform sampler2D uDepthBuffer2; // static
uniform float uCascadeEndClipSpace[NUM_CASCADES]; // static
uniform int uCascadeCount; // static
uniform int uShadowBlurQuality; // static
uniform vec2 uPCSSKernel[64]; // static
uniform float uSunShadowScale; // static
uniform vec2 uScreenSize; // static

uniform vec3 uSSSRadius;
uniform float uLightSpecular;

uniform vec3 uCameraPosition; // static
uniform float uGamma;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec2 vTexCoord;
varying vec4 vScreenCoord0;
varying vec4 vScreenCoord1;
varying vec4 vScreenCoord2;
varying vec4 vCustom;
varying vec4 vClipPosition;
varying float vClipSpaceDepth;
varying vec4 vColor;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_material.SPECULAR_LIB)
#pragma shady: inline(common_material.SSS_TRANSLUCENCY_LIB)
#pragma shady: inline(common_shadows.PCSS_LIB)

float cascadeDepthBuffer(int index, vec2 coord)
{
	if (index == 0)
		return texture2D(uDepthBuffer0, coord).r;
	else if (index == 1)
		return texture2D(uDepthBuffer1, coord).r;
	else
		return texture2D(uDepthBuffer2, coord).r;
}

float getSunShadow(int cascade, vec2 coord, float fragDepth, float depthRange, vec2 receiverDepthGradient, float bias, out float centerDepth)
{
	centerDepth = uSunNear[cascade] + cascadeDepthBuffer(cascade, coord) * depthRange;
	
	int quality = uShadowBlurQuality;
	if (quality > PCSS_MAX_SAMPLES)
		quality = PCSS_MAX_SAMPLES;
	
	if (quality <= 0 || uSunShadowScale <= 0.0)
		return getPCSSVisibility(fragDepth, centerDepth, bias);
	
	vec2 rotation = getPCSSPixelRotation(vClipPosition, uScreenSize);
	int blockerSamples = getPCSSBlockerSamples(quality);
	float cascadeScale = uCascadeWorldSize[0] / max(uCascadeWorldSize[cascade], 0.0001);
	float searchRadius = (uSunShadowScale * 8.0 / PCSS_REFERENCE_SHADOW_SIZE) * cascadeScale;
	float searchBias = bias + min(length(receiverDepthGradient) * searchRadius, bias * 2.0);
	float blockerDepth = 0.0;
	float blockers = 0.0;
	
	// Blocker search
	for (int blockerIndex = 0; blockerIndex < PCSS_MAX_BLOCKER_SAMPLES; blockerIndex++)
	{
		if (blockerIndex >= blockerSamples)
			break;
		
		vec2 sampleCoord = clamp(coord + getPCSSSampleOffset(blockerIndex, rotation) * searchRadius, vec2(0.0), vec2(1.0));
		float sampleDepth = uSunNear[cascade] + cascadeDepthBuffer(cascade, sampleCoord) * depthRange;
		if (isPCSSBlocker(fragDepth, sampleDepth, searchBias))
		{
			blockerDepth += sampleDepth;
			blockers += 1.0;
		}
	}
	
	if (blockers == 0.0)
		return 1.0;
	
	blockerDepth /= blockers;
	
	// Get penumbra for filter
	float separation = max(fragDepth - blockerDepth - bias, 0.0) / max(depthRange, 0.0001); // Ignore the bias gap
	float filterRadius = min(uSunShadowScale * separation * cascadeScale, 64.0 / PCSS_REFERENCE_SHADOW_SIZE);
	float filterBias = bias + min(length(receiverDepthGradient) * filterRadius, bias * 2.0);
	float visibility = 0.0;
	
	// Filter shadow
	for (int filterIndex = 0; filterIndex < PCSS_MAX_SAMPLES; filterIndex++)
	{
		if (filterIndex >= quality)
			break;
		
		vec2 sampleCoord = clamp(coord + getPCSSSampleOffset(filterIndex, rotation) * filterRadius, vec2(0.0), vec2(1.0));
		float sampleDepth = uSunNear[cascade] + cascadeDepthBuffer(cascade, sampleCoord) * depthRange;
		visibility += getPCSSVisibility(fragDepth, sampleDepth, filterBias);
	}
	
	return visibility / float(quality);
}

void main()
{
	vec3 light, spec;
	light = vec3(0.0);
	spec = vec3(0.0);
	
	vec2 tex = vTexCoord;
	vec4 baseColor = texture2D(uTexture, tex) * vColor;
	vec3 lightCol = uLightColor.rgb * uLightStrength;
	vec2 receiverDepthGradient0 = getPCSSReceiverDepthGradient(vScreenCoord0.xy, vScreenCoord0.z);
	vec2 receiverDepthGradient1 = getPCSSReceiverDepthGradient(vScreenCoord1.xy, vScreenCoord1.z);
	vec2 receiverDepthGradient2 = getPCSSReceiverDepthGradient(vScreenCoord2.xy, vScreenCoord2.z);
	
	handleAlphaDiscard(vPosition, baseColor);
	
	if (uIsSky == 0)
	{
		// Get material data
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		
		vec3 normal = getMaterialNormal(vTexCoord, vPosition, getTBN(vNormal, vTangent));
		vec3 subsurfaceRadius = uSSSRadius * sss;
		vec3 baseColorLinear = pow(baseColor.rgb, vec3(uGamma));
		vec3 specularF0 = mix(vec3(F0), baseColorLinear, metallic);
		vec3 F = getDirectFresnel(normal, uLightDirection, uCameraPosition, vPosition, specularF0);
		
		// Diffuse factor
		float dif = clamp(max(0.0, dot(normal, uLightDirection)), 0.0, 1.0);	
		
		vec3 shadow = vec3(1.0);
		vec3 subsurf = vec3(0.0);
		
		if (dif > 0.0 || sss > 0.0)
		{
			// Find the cascade to use
			int i;
			for (i = 0; i < uCascadeCount; i++)
				if (vClipSpaceDepth < uCascadeEndClipSpace[i])
					break;
			bool cascadeValid = i < uCascadeCount;
			if (i >= uCascadeCount)
				i = uCascadeCount - 1;
			
			vec4 screenCoord;
			vec2 receiverDepthGradient;
			if (i == 0)
			{
				screenCoord = vScreenCoord0;
				receiverDepthGradient = receiverDepthGradient0;
			}
			else if (i == 1)
			{
				screenCoord = vScreenCoord1;
				receiverDepthGradient = receiverDepthGradient1;
			}
			else
			{
				i = 2;
				screenCoord = vScreenCoord2;
				receiverDepthGradient = receiverDepthGradient2;
			}
			
			float fragDepth = screenCoord.z;
			vec2 fragCoord = screenCoord.xy;
			
			// Texture position must be valid
			if (cascadeValid && fragCoord.x >= 0.0 && fragCoord.y >= 0.0 && fragCoord.x <= 1.0 && fragCoord.y <= 1.0)
			{	
				// Convert 0->1 to Near->Far
				float depthRange = uSunFar[i] - uSunNear[i];
				fragDepth = uSunNear[i] + fragDepth * depthRange;
				receiverDepthGradient *= depthRange;
				
				// Calculate bias
				float bias = 1.0 + (float(i) * 2.0);
				
				// Find shadow
				float sampleDepth;
				shadow *= vec3(getSunShadow(i, fragCoord, fragDepth, depthRange, receiverDepthGradient, bias, sampleDepth));
				
				// Subsurface translucency
				if (sss > 0.0 && dif == 0.0)
					subsurf += getSubsurfaceTranslucency(fragDepth, sampleDepth, subsurfaceRadius);
			}
		}
		
		// Diffuse light
		light = lightCol * dif * shadow;
		
		// Subsurface highlight
		if (sss > 0.0)
			handleSubsurfaceHighlight(light, subsurf, normal, uLightDirection, lightCol, uCameraPosition, vPosition, sss, 1.0);
		
		light *= (vec3(1.0) - F) * (1.0 - metallic);
		
		// Calculate specular
		if (uLightSpecular * dif * shadow.r > 0.0)
		{
			vec3 specular = getSpecular(normal, uLightDirection, uCameraPosition, vPosition, specularF0, roughness);
			spec = uLightColor.rgb * uLightSpecular * dif * shadow * specular;
		}
	}
	
	// Set final color
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
}
