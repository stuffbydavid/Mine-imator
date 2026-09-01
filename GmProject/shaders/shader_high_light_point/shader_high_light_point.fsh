#define SQRT05 0.707106781

uniform sampler2D uTexture; // static
uniform int uIsSky;
uniform int uIsWater;

uniform vec3 uLightPosition; // static
uniform vec4 uLightColor; // static
uniform float uLightStrength; // static
uniform float uLightNear; // static
uniform float uLightFar; // static
uniform float uLightFadeSize; // static
uniform vec3 uShadowPosition; // static
uniform float uLightSpecular;
uniform float uLightSize;

uniform sampler2D uDepthBuffer; // static
uniform float uDepthBufferSize; // static

uniform vec3 uCameraPosition; // static

uniform vec3 uSSSRadius;

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
#pragma shady: inline(common_material.SPECULAR_LIB)
#pragma shady: inline(common_material.SSS_TRANSLUCENCY_LIB)
#pragma shady: inline(common_constants.MATH)

vec2 getShadowMapCoord(vec3 look)
{
	float tFOV = tan(PI / 4.0);
	vec3 u, v, toPoint = vPosition - uShadowPosition;
	vec2 coord;
	
	// Prepare 3D to 2D conversion
	look /= sqrt(dot(look, look));
	u = vec3(-look.z * look.x, -look.z * look.y, 1.0 - look.z * look.z);
	u /= sqrt(dot(u, u));
	u *= tFOV; 
	v = vec3(u.y * look.z - look.y * u.z, u.z * look.x - look.z * u.x, u.x * look.y - look.x * u.y);
	
	// Convert
	toPoint /= dot(toPoint,look);
	coord.x = (dot(toPoint, v) / (tFOV * tFOV) + 1.0) * 0.5;
	coord.y = (1.0 - dot(toPoint, u) / (tFOV * tFOV)) * 0.5;
	
	coord.x /= 3.0;
	coord.y *= 0.5;
	
	return coord;
}

// Linear filtering, done in-shader as we use a texture atlas
float getFilteredDepth(vec2 uv, vec2 uvMin)
{
	float samples = 0.0;
	vec2 sampleuv, uvMax, texelOffset;
	float depth = 0.0;
	texelOffset = vec2((1.0/vec2(uDepthBufferSize * 3.0, uDepthBufferSize * 2.0)) * 0.5);
	uvMax = uvMin + vec2(1.0/3.0, 0.5);
	
	// Top left
	sampleuv = uv - texelOffset.x;
	if (sampleuv.x > uvMin.x && sampleuv.x < uvMax.x &&
		sampleuv.y > uvMin.y && sampleuv.y < uvMax.y)
	{
		depth += texture2D(uDepthBuffer, sampleuv).r;
		samples += 1.0;
	}
	
	// Top right
	sampleuv.y = uv.y - texelOffset.x;
	sampleuv.x = uv.x + texelOffset.y;
	if (sampleuv.x > uvMin.x && sampleuv.x < uvMax.x &&
		sampleuv.y > uvMin.y && sampleuv.y < uvMax.y)
	{
		depth += texture2D(uDepthBuffer, sampleuv).r;
		samples += 1.0;
	}
	
	// Bottom left
	sampleuv.y = uv.y + texelOffset.x;
	sampleuv.x = uv.x - texelOffset.y;
	if (sampleuv.x > uvMin.x && sampleuv.x < uvMax.x &&
		sampleuv.y > uvMin.y && sampleuv.y < uvMax.y)
	{
		depth += texture2D(uDepthBuffer, sampleuv).r;
		samples += 1.0;
	}
	
	// Bottom right
	sampleuv = uv + texelOffset;
	if (sampleuv.x > uvMin.x && sampleuv.x < uvMax.x &&
		sampleuv.y > uvMin.y && sampleuv.y < uvMax.y)
	{
		depth += texture2D(uDepthBuffer, sampleuv).r;
		samples += 1.0;
	}
	
	return depth / samples;
}

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
		
		float shadow = 1.0;
		float att = 0.0;
		vec3 subsurf = vec3(0.0);
		
		// Diffuse factor
		float dif = max(0.0, dot(normal, lightDir));
		
		// Attenuation factor
		att = 1.0 - clamp((distance(vPosition, uLightPosition) - uLightFar * (1.0 - uLightFadeSize)) / (uLightFar * uLightFadeSize), 0.0, 1.0); 
		dif *= att;
		
		if (dif > 0.0 || sss > 0.0)
		{
			vec2 fragCoord, bufferMin, bufferMax;
			vec3 toLight = vPosition - uShadowPosition;
			vec4 lookDir = vec4( // Get the direction from the pixel to the light
				toLight.x / distance(vPosition.xy, uShadowPosition.xy),
				toLight.y / distance(vPosition.xy, uShadowPosition.xy),
				toLight.z / distance(vPosition.xz, uShadowPosition.xz),
				toLight.z / distance(vPosition.yz, uShadowPosition.yz)
			);
		
			// Get shadow map and texture coordinate
		
			// Z+
			// ooo
			// oxo
			if (lookDir.z > SQRT05 && lookDir.w > SQRT05)
			{ 
				fragCoord = getShadowMapCoord(vec3(0.0, -0.0001, 1.0));
				fragCoord.x += 1.0/3.0;
				fragCoord.y += 0.5;
				
				bufferMin = vec2(1.0/3.0, 0.5);
			}
			
			// Z-
			// ooo
			// oox
			else if (lookDir.z < -SQRT05 && lookDir.w < -SQRT05)
			{
				fragCoord = getShadowMapCoord(vec3(0.0, -0.0001, -1.0));
				fragCoord.x += 2.0/3.0;
				fragCoord.y += 0.5;
				
				bufferMin = vec2(2.0/3.0, 0.5);
			}
		
			// X+
			// xoo
			// ooo
			else if (lookDir.x > SQRT05)
			{ 
				fragCoord = getShadowMapCoord(vec3(1.0, 0.0, 0.0));
				
				bufferMin = vec2(0.0);
			}
		
			// X-
			// oxo
			// ooo
			else if (lookDir.x < -SQRT05)
			{
				fragCoord = getShadowMapCoord(vec3(-1.0, 0.0, 0.0));
				fragCoord.x += 1.0/3.0;
				
				bufferMin = vec2(1.0/3.0, 0.0);
			}
		
			// Y+
			// oox
			// ooo
			else if (lookDir.y > SQRT05)
			{ 
				fragCoord = getShadowMapCoord(vec3(0.0, 1.0, 0.0));
				fragCoord.x += 2.0/3.0;
				
				bufferMin = vec2(2.0/3.0, 0.0);
			}
		
			// Y-
			// ooo
			// xoo
			else
			{ 
				fragCoord = getShadowMapCoord(vec3(0.0, -1.0, 0.0));
				fragCoord.y += 0.5;
				
				bufferMin = vec2(0.0, 0.5);
			}
			
			// Calculate bias
			float bias = 1.0;
			
			// Shadow
			float fragDepth = distance(vPosition, uShadowPosition);
			float sampleDepth = uLightNear + (uLightFar - uLightNear) * getFilteredDepth(fragCoord, bufferMin);
			shadow = ((fragDepth - bias) > sampleDepth) ? 0.0 : 1.0;
			
			// Subsurface translucency
			if (sss > 0.0 && dif == 0.0)
				subsurf = getSubsurfaceTranslucency(fragDepth, sampleDepth, bias, lightCol, uSSSRadius * sss) * att;
		}
		
		// Diffuse light
		light = lightCol * dif * shadow;
		
		// Subsurface highlight
		if (sss > 0.0)
			handleSubsurfaceHighlight(light, subsurf, normal, lightDir, lightCol, uCameraPosition, vPosition, sss, 1.0);
		
		// Calculate specular
		if (uLightSpecular * dif * shadow > 0.0)
		{
			float specular = getSpecular(normal, lightDir, uCameraPosition, vPosition, F0, roughness, metallic);
		
			spec = uLightColor.rgb * shadow * uLightSpecular * dif * (specular * mix(vec3(1.0), baseColor.rgb, metallic));
		}
	}
	
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
}
