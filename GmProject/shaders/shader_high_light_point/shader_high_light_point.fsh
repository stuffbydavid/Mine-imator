uniform sampler2D uTexture; // static
uniform int uIsSky;

uniform vec3 uLightPosition; // static
uniform vec3 uLightDirection; // static
uniform vec3 uLightAreaCenter; // static
uniform vec3 uLightAreaU; // static
uniform vec3 uLightAreaV; // static
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
uniform vec2 uScreenSize; // static

uniform vec3 uCameraPosition; // static
uniform float uGamma;

uniform vec3 uSSSRadius;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec2 vTexCoord;
varying vec4 vCustom;
varying vec4 vColor;
varying vec4 vClipPosition;

#pragma shady: inline(common_material.MATERIAL_LIB)
#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_material.FRESNEL_LIB)
#pragma shady: inline(common_material.SPECULAR_LIB)
#pragma shady: inline(common_material.AREA_LIGHT_LIB)
#pragma shady: inline(common_material.SSS_TRANSLUCENCY_LIB)
#pragma shady: inline(common_constants.MATH)
#pragma shady: inline(common_shadows.PCSS_LIB)

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

float getFilteredDepth(vec2 uv, vec2 uvMin)
{
	vec2 halfTexel = 0.5 / vec2(uDepthBufferSize * 3.0, uDepthBufferSize * 2.0);
	vec2 uvMax = uvMin + vec2(1.0/3.0, 0.5);
	return texture2D(uDepthBuffer, clamp(uv, uvMin + halfTexel, uvMax - halfTexel)).r;
}

float getPointDepth(vec3 direction)
{
	vec2 bufferMin;
	vec2 coord = getPointShadowMapCoord(direction, bufferMin);
	return uLightNear + (uLightFar - uLightNear) * getFilteredDepth(coord, bufferMin);
}

vec3 getPointSampleDirection(vec3 direction, vec3 tangent, vec3 bitangent, vec2 offset, float radius)
{
	return normalize(direction + (tangent * offset.x + bitangent * offset.y) * radius);
}

float getPointReceiverDepth(vec3 direction, vec3 receiverPosition, vec3 receiverNormal, float fallbackDepth)
{
	float denominator = dot(direction, receiverNormal);
	if (abs(denominator) < 0.0001)
		return fallbackDepth;
	
	float depth = dot(receiverPosition, receiverNormal) / denominator;
	return depth > 0.0 ? depth : fallbackDepth;
}

float getPointShadow(vec3 toReceiver, float fragDepth, vec3 receiverNormal, float bias, out float centerDepth)
{
	vec3 direction = toReceiver / max(fragDepth, 0.0001);
	centerDepth = getPointDepth(direction);
	
	int quality = uShadowBlurQuality;
	if (quality > PCSS_MAX_SAMPLES)
		quality = PCSS_MAX_SAMPLES;
	
	if (quality <= 0 || uShadowRadius <= 0.0)
		return getPCSSVisibility(fragDepth, centerDepth, bias);
	
	vec3 reference = abs(direction.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
	vec3 tangent = normalize(cross(reference, direction));
	vec3 bitangent = cross(direction, tangent);
	vec3 receiverPosition = toReceiver;
	vec2 rotation = getPCSSPixelRotation(vClipPosition, uScreenSize);
	int blockerSamples = getPCSSBlockerSamples(quality);
	float searchRadius = min(uShadowRadius / max(fragDepth, uLightNear), 128.0 / PCSS_REFERENCE_SHADOW_SIZE);
	float blockerDepth = 0.0;
	float blockers = 0.0;
	
	// Blocker search
	for (int blockerIndex = 0; blockerIndex < PCSS_MAX_BLOCKER_SAMPLES; blockerIndex++)
	{
		if (blockerIndex >= blockerSamples)
			break;
		
		vec2 offset = getPCSSSampleOffset(blockerIndex, rotation);
		vec3 sampleDirection = getPointSampleDirection(direction, tangent, bitangent, offset, searchRadius);
		float sampleDepth = getPointDepth(sampleDirection);
		float receiverDepth = getPointReceiverDepth(sampleDirection, receiverPosition, receiverNormal, fragDepth);
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
	float penumbraRadius = uShadowRadius * max(fragDepth - blockerDepth - bias, 0.0) / max(blockerDepth, uLightNear); // Ignore the bias gap
	float filterRadius = min(penumbraRadius / max(fragDepth, uLightNear), 128.0 / PCSS_REFERENCE_SHADOW_SIZE);
	float visibility = 0.0;
	
	// Filter shadow
	for (int filterIndex = 0; filterIndex < PCSS_MAX_SAMPLES; filterIndex++)
	{
		if (filterIndex >= quality)
			break;
		
		vec2 offset = getPCSSSampleOffset(filterIndex, rotation);
		vec3 sampleDirection = getPointSampleDirection(direction, tangent, bitangent, offset, filterRadius);
		float sampleDepth = getPointDepth(sampleDirection);
		float receiverDepth = getPointReceiverDepth(sampleDirection, receiverPosition, receiverNormal, fragDepth);
		visibility += getPCSSVisibility(receiverDepth, sampleDepth, bias);
	}
	
	return visibility / float(quality);
}

vec2 getAreaQuadrature(int index)
{
	if (index == 0)
		return vec2(-0.8611363116, 0.3478548451);
	if (index == 1)
		return vec2(-0.3399810436, 0.6521451549);
	if (index == 2)
		return vec2(0.3399810436, 0.6521451549);
	return vec2(0.8611363116, 0.3478548451);
}

float getAreaRadianceScale(float distance2)
{
	float att = getLightAttenuation(sqrt(distance2), uLightFar, uLightFadeSize, uLightRealisticFalloff);
	// Rectangles already have finite irradiance at contact; remove the point-source softening
	return att * (uLightRealisticFalloff > 0 ? distance2 + 256.0 : distance2);
}

vec2 getAreaSpecularQuadrature(int index, float focus, float width)
{
	vec2 q = getAreaQuadrature(index);
	if (width <= 0.0 || abs(focus) > 1.5)
		return q;

	// Change variables around the reflected GGX peak so smooth metals do not miss the emitter
	float lower = atan((-1.0 - focus) / width, 1.0);
	float upper = atan((1.0 - focus) / width, 1.0);
	float halfRange = (upper - lower) * 0.5;
	float tangent = tan((lower + upper) * 0.5 + q.x * halfRange);
	return vec2(focus + width * tangent, q.y * width * (1.0 + tangent * tangent) * halfRange);
}

vec3 getRectangleSpecular(vec3 normal, vec3 specularF0, float roughness, float radianceScale)
{
	if (dot(uLightDirection, vPosition - uLightPosition) <= 0.00001 || getRectangleArea(uLightAreaU, uLightAreaV) <= 0.00000001)
		return vec3(0.0);

	vec3 view = normalize(uCameraPosition - vPosition);
	vec3 reflected = reflect(-view, normal);
	float denominator = dot(reflected, uLightDirection);
	vec2 focus = vec2(0.0);
	vec2 width = vec2(0.0);
	if (abs(denominator) > 0.0001)
	{
		float rayDistance = dot(uLightPosition - vPosition, uLightDirection) / denominator;
		if (rayDistance > 0.0)
		{
			vec3 hit = vPosition + reflected * rayDistance - uLightPosition;
			focus = vec2(dot(hit, uLightAreaU) / dot(uLightAreaU, uLightAreaU), dot(hit, uLightAreaV) / dot(uLightAreaV, uLightAreaV));
			float alpha = max(roughness, MIN_PERCEPTUAL_ROUGHNESS);
			float footprint = 2.0 * alpha * alpha * rayDistance / max(abs(denominator), 0.1);
			width = footprint / vec2(length(uLightAreaU), length(uLightAreaV));
		}
	}

	vec3 result = vec3(0.0);
	for (int y = 0; y < 4; y++)
	{
		vec2 qy = getAreaSpecularQuadrature(y, focus.y, width.y);
		for (int x = 0; x < 4; x++)
		{
			vec2 qx = getAreaSpecularQuadrature(x, focus.x, width.x);
			vec3 delta = uLightPosition + uLightAreaU * qx.x + uLightAreaV * qy.x - vPosition;
			float distance2 = max(dot(delta, delta), 0.00000001);
			vec3 direction = delta / sqrt(distance2);
			float geometry = max(dot(normal, direction), 0.0) * max(dot(uLightDirection, -direction), 0.0) / distance2;
			result += getSpecular(normal, direction, uCameraPosition, vPosition, specularF0, roughness) *
				(geometry * radianceScale * qx.y * qy.y * 0.25);
		}
	}
	return result;
}

void main()
{
	vec3 light = vec3(0.0);
	vec3 spec = vec3(0.0);
	
	vec2 tex = vTexCoord;
	vec4 baseColor = texture2D(uTexture, tex) * vColor;
	vec3 lightCol = uLightColor.rgb * uLightStrength;
	vec3 receiverNormal = cross(dFdx(vPosition), dFdy(vPosition));
	float receiverNormalLength = length(receiverNormal);
	receiverNormal = receiverNormalLength > 0.000001 ? receiverNormal / receiverNormalLength : normalize(vNormal);
	if (dot(receiverNormal, vNormal) < 0.0)
		receiverNormal *= -1.0;
	
	handleAlphaDiscard(vPosition, baseColor);
	
	if (uIsSky == 0)
	{
		// Get material data
		float roughness, metallic, emissive, F0, sss;
		getMaterial(roughness, metallic, emissive, F0, sss);
		vec3 normal = getMaterialNormal(vTexCoord, vPosition, getTBN(vNormal, vTangent));
		vec3 lightVector = (dot(uLightDirection, uLightDirection) > 0.0 ? uLightAreaCenter : uLightPosition) - vPosition;
		vec3 lightDir = lightVector / max(length(lightVector), 0.0001);
		vec3 baseColorLinear = pow(baseColor.rgb, vec3(uGamma));
		vec3 specularF0 = mix(vec3(F0), baseColorLinear, metallic);
		vec3 F = getDirectFresnel(normal, lightDir, uCameraPosition, vPosition, specularF0);

		if (dot(uLightDirection, uLightDirection) > 0.0)
		{
			float area = getRectangleArea(uLightAreaU, uLightAreaV);
			float distance2 = dot(uLightAreaCenter - vPosition, uLightAreaCenter - vPosition);
			float radianceScale = getAreaRadianceScale(distance2);
			float radiance = radianceScale / max(area, 0.00000001);
			float dif = getRectangleIrradiance(vPosition, normal, uLightPosition, uLightDirection, uLightAreaU, uLightAreaV) * radiance;
			vec3 areaSpecular = uLightSpecular > 0.0 ? getRectangleSpecular(normal, specularF0, roughness, radianceScale) : vec3(0.0);
			float shadow = 1.0;
			vec3 subsurf = vec3(0.0);
			if (dif > 0.0 || dot(areaSpecular, areaSpecular) > 0.0 || sss > 0.0)
			{
				float fragDepth = distance(vPosition, uShadowPosition);
				float sampleDepth;
				shadow = getPointShadow(vPosition - uShadowPosition, fragDepth, receiverNormal, 1.0, sampleDepth);
				if (sss > 0.0 && dif == 0.0)
				{
					float backlight = getRectangleIrradiance(vPosition, -normal, uLightPosition, uLightDirection, uLightAreaU, uLightAreaV) * radiance;
					subsurf = getSubsurfaceTranslucency(fragDepth, sampleDepth, uSSSRadius * sss) * backlight;
				}
			}
			light = lightCol * dif * shadow;
			if (sss > 0.0)
				handleSubsurfaceHighlight(light, subsurf, normal, lightDir, lightCol, uCameraPosition, vPosition, sss, 1.0);
			light *= (vec3(1.0) - F) * (1.0 - metallic);
			float specularStrength = uLightSpecular * (uLightRealisticFalloff > 0 ? uLightStrength : 1.0);
			spec = uLightColor.rgb * areaSpecular * shadow * specularStrength;
			gl_FragData[0] = vec4(light, baseColor.a);
			gl_FragData[1] = vec4(spec, baseColor.a);
			return;
		}
		
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
