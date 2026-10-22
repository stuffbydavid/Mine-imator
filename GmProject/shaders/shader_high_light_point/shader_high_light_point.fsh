uniform sampler2D uTexture; // static
uniform int uIsSky;

uniform vec3 uLightPosition; // static
uniform vec4 uLightColor; // static
uniform float uLightStrength; // static
uniform float uLightNear; // static
uniform float uLightFar; // static
uniform float uLightFadeSize; // static
uniform int uLightRealisticFalloff;
uniform vec3 uShadowPosition; // static
uniform float uLightSpecular;
uniform float uLightSize;
uniform float uShadowRadius; // static

uniform sampler2D uDepthBuffer; // static
uniform float uDepthBufferSize; // static
uniform int uShadowBlurQuality; // static
uniform vec2 uPCSSKernel[64]; // static

uniform vec3 uCameraPosition; // static
uniform float uGamma;

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
#pragma shady: inline(common_pcss.PCSS_COMMON_LIB)
#pragma shady: inline(common_shadows.PCSS_PLANE_LIB)

vec2 getShadowMapCoord(vec3 look, vec3 toPoint)
{
	float tFOV = tan(PI / 4.0);
	vec3 u, v;
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

vec2 getPointShadowMapCoord(vec3 direction, out vec2 bufferMin)
{
	vec3 directionAbs = abs(direction);
	vec3 look;
	
	// Z faces
	if (directionAbs.z >= directionAbs.x && directionAbs.z >= directionAbs.y)
	{
		// Z+
		// ooo
		// oxo
		if (direction.z >= 0.0)
		{
			look = vec3(0.0, -0.0001, 1.0);
			bufferMin = vec2(1.0/3.0, 0.5);
		}
		else
		{
			// Z-
			// ooo
			// oox
			look = vec3(0.0, -0.0001, -1.0);
			bufferMin = vec2(2.0/3.0, 0.5);
		}
	}
	// X faces
	else if (directionAbs.x >= directionAbs.y)
	{
		// X+
		// xoo
		// ooo
		if (direction.x >= 0.0)
		{
			look = vec3(1.0, 0.0, 0.0);
			bufferMin = vec2(0.0);
		}
		else
		{
			// X-
			// oxo
			// ooo
			look = vec3(-1.0, 0.0, 0.0);
			bufferMin = vec2(1.0/3.0, 0.0);
		}
	}
	// Y faces
	else
	{
		// Y+
		// oox
		// ooo
		if (direction.y >= 0.0)
		{
			look = vec3(0.0, 1.0, 0.0);
			bufferMin = vec2(2.0/3.0, 0.0);
		}
		else
		{
			// Y-
			// ooo
			// xoo
			look = vec3(0.0, -1.0, 0.0);
			bufferMin = vec2(0.0, 0.5);
		}
	}
	
	return getShadowMapCoord(look, direction) + bufferMin;
}

vec3 getPointSampleDirection(vec3 direction, vec3 tangent, vec3 bitangent, vec2 offset, float radius)
{
	return normalize(direction + (tangent * offset.x + bitangent * offset.y) * radius);
}

// Reconstruct the ray through a texel on the selected atlas face
vec3 getPointTexelDirection(vec2 coord, vec2 low)
{
	vec3 look;
	if (low.y > 0.0)
	{
		// Bottom atlas row: Y-, Z+, Z-
		if (low.x < 0.1)
			look = vec3(0.0, -1.0, 0.0);
		else if (low.x < 0.5)
			look = vec3(0.0, -0.0001, 1.0);
		else
			look = vec3(0.0, -0.0001, -1.0);
	}
	else if (low.x < 0.1)
		look = vec3(1.0, 0.0, 0.0);
	else if (low.x < 0.5)
		look = vec3(-1.0, 0.0, 0.0);
	else
		look = vec3(0.0, 1.0, 0.0);

	// Match the basis used by getShadowMapCoord, including the Z-face tilt
	look = normalize(look);
	vec3 up = normalize(vec3(-look.z * look.x, -look.z * look.y, 1.0 - look.z * look.z));
	vec3 right = cross(up, look);

	// Convert atlas coordinates back to face coordinates before forming the ray
	vec2 uv = (coord - low) * vec2(3.0, 2.0);
	return normalize(look + right * (uv.x * 2.0 - 1.0) + up * (1.0 - uv.y * 2.0));
}

struct ShadowReceiver
{
	float depth;
	float bias;
	float localRadius;
	float searchRadius;
	float lightRadius;
	float radiusScale;
	float nearDepth;
	bool perspective;

	vec3 direction;
	vec3 position;
	vec3 normal;
	vec3 tangent;
	vec3 bitangent;
};

float getPointTexelDepth(vec2 coord)
{
	return uLightNear + (uLightFar - uLightNear) * texture2D(uDepthBuffer, coord).r;
}

float getShadowSampleDepth(ShadowReceiver receiver, vec2 offset, out float surfaceDepth)
{
	vec3 sampleDirection = getPointSampleDirection(receiver.direction, receiver.tangent, receiver.bitangent, offset, 1.0);
	vec2 mapMin;
	vec2 coord = getPointShadowMapCoord(sampleDirection, mapMin);
	vec2 texelCoord = getShadowTexelCoord(coord, uDepthBufferSize * vec2(3.0, 2.0), mapMin, mapMin + vec2(1.0 / 3.0, 0.5));
	vec3 ray = getPointTexelDirection(texelCoord, mapMin);
	surfaceDepth = getPCSSRayDepth(ray, receiver.position, receiver.normal, receiver.depth);
	return getPointTexelDepth(texelCoord);
}

#pragma shady: inline(common_pcss.PCSS_FILTER_LIB)

float getPointShadow(vec3 toReceiver, float fragDepth, vec3 receiverNormal, float bias, out float centerDepth)
{
	vec3 direction = toReceiver / max(fragDepth, 0.0001);
	vec2 mapMin;
	vec2 coord = getPointShadowMapCoord(direction, mapMin);
	vec2 centerCoord = getShadowTexelCoord(coord, uDepthBufferSize * vec2(3.0, 2.0), mapMin, mapMin + vec2(1.0 / 3.0, 0.5));
	centerDepth = getPointTexelDepth(centerCoord);
	vec3 ray = getPointTexelDirection(centerCoord, mapMin);
	float surfaceDepth = getPCSSRayDepth(ray, toReceiver, receiverNormal, fragDepth);
	if (uShadowBlurQuality <= 0 || uShadowRadius <= 0.0)
		return getPCSSVisibility(surfaceDepth, centerDepth, bias);

	vec3 reference = abs(direction.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);

	ShadowReceiver receiver;
	receiver.depth = fragDepth;
	receiver.bias = bias;
	// Cover the full blur range
	receiver.searchRadius = 128.0 / PCSS_REFERENCE_SHADOW_SIZE;
	float minimumRadius = getShadowMinimumRadius(uShadowRadius, uLightSize * 0.5, max(fragDepth, uLightNear), uDepthBufferSize, receiver.searchRadius);
	// Half a face texel in angular coordinates
	float localRadius = min(uShadowRadius / max(fragDepth, uLightNear), 1.0 / uDepthBufferSize);
	receiver.localRadius = min(max(localRadius, minimumRadius), receiver.searchRadius);
	receiver.lightRadius = uShadowRadius;
	receiver.radiusScale = 1.0 / max(fragDepth, uLightNear);
	receiver.nearDepth = uLightNear;
	receiver.perspective = true;
	receiver.direction = direction;
	receiver.position = toReceiver;
	receiver.normal = receiverNormal;
	receiver.tangent = normalize(cross(reference, direction));
	receiver.bitangent = cross(direction, receiver.tangent);

	return getPCSSShadow(receiver, uShadowBlurQuality, minimumRadius, centerDepth, surfaceDepth);
}

void main()
{
	vec3 light = vec3(0.0);
	vec3 spec = vec3(0.0);
	
	vec2 tex = vTexCoord;
	vec4 baseColor = texture2D(uTexture, tex) * vColor;
	vec3 lightCol = uLightColor.rgb * uLightStrength;
	vec3 receiverNormal = normalize(vNormal);
	
	handleAlphaDiscard(vPosition, baseColor);
	
	if (uIsSky == 0)
	{
		// Get material data
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		vec3 normal = getMaterialNormal(vTexCoord, vPosition, getTBN(vNormal, vTangent));
		vec3 lightDir = normalize(uLightPosition - vPosition);
		vec3 baseColorLinear = pow(baseColor.rgb, vec3(uGamma));
		vec3 specularF0 = mix(vec3(F0), baseColorLinear, metallic);
		vec3 F = getDirectFresnel(normal, lightDir, uCameraPosition, vPosition, specularF0);
		
		float shadow = 1.0;
		float att = 0.0;
		vec3 subsurf = vec3(0.0);
		
		// Diffuse factor
		float dif = max(0.0, dot(normal, lightDir));
		
		// Attenuation factor
		att = getLightAttenuation(distance(vPosition, uLightPosition), uLightFar, uLightFadeSize, uLightRealisticFalloff);
		dif *= att;
		
		if (dif > 0.0 || sss > 0.0)
		{
			vec3 toLight = vPosition - uShadowPosition;
			
			// Calculate bias
			float bias = 1.0;
			
			// Shadow
			float fragDepth = distance(vPosition, uShadowPosition);
			float sampleDepth;
			shadow = getPointShadow(toLight, fragDepth, receiverNormal, bias, sampleDepth);
			
			// Subsurface translucency
			if (sss > 0.0 && dif == 0.0)
				subsurf = getSubsurfaceTranslucency(fragDepth, sampleDepth, uSSSRadius * sss) * att;
		}
		
		// Diffuse light
		light = lightCol * dif * shadow;
		
		// Subsurface highlight
		if (sss > 0.0)
			handleSubsurfaceHighlight(light, subsurf, normal, lightDir, lightCol, uCameraPosition, vPosition, sss, 1.0);
		
		light *= (vec3(1.0) - F) * (1.0 - metallic);
		
		// Calculate specular
		if (uLightSpecular * dif * shadow > 0.0)
		{
			float sphereNormalization;
			vec3 sphereLightDir = getSphereLightDirection(normal, uCameraPosition, vPosition, uLightPosition - vPosition, uLightSize * 0.5, roughness, sphereNormalization);
			vec3 specular = getSpecular(normal, sphereLightDir, uCameraPosition, vPosition, specularF0, roughness) * sphereNormalization;
			float specularStrength = uLightSpecular * (uLightRealisticFalloff > 0 ? uLightStrength : 1.0);
			spec = uLightColor.rgb * shadow * specularStrength * dif * specular;
		}
	}
	
	gl_FragData[0] = vec4(light, baseColor.a);
	gl_FragData[1] = vec4(spec, baseColor.a);
}
