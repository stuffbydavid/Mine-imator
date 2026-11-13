#define MAX_SAMPLES 33

uniform sampler2D uSSSBuffer;
uniform sampler2D uSSSRangeBuffer;
uniform sampler2D uDepthBuffer;
uniform sampler2D uDirect;
uniform sampler2D uNoiseBuffer;

// Camera data
uniform mat4 uProjMatrix;
uniform float uNear;
uniform float uFar;
uniform vec2 uScreenSize;

uniform int uSamples;
uniform float uNoiseSize;
uniform vec3 uKernel[MAX_SAMPLES]; // xy = disk offset, z = weight

varying vec2 vTexCoord;

#pragma shady: inline(common_util.DEPTH_BUFFER_LIB)
#pragma shady: inline(common_constants.MATH)

float getDepth(vec2 coord)
{
	return uNear + readDepth(coord) * (uFar - uNear);
}

void main()
{
	vec3 lightOrigin = texture2D(uDirect, vTexCoord).rgb;
	float sss = texture2D(uSSSBuffer, vTexCoord).r;
	
	// Early exit
	if (sss < 0.001)
	{
		gl_FragColor = vec4(lightOrigin, 1.0);
	}
	else
	{
		vec3 sssRange = texture2D(uSSSRangeBuffer, vTexCoord).rgb;
		float viewDepth = getDepth(vTexCoord);
		
		// Keep blur consistent with pixel depth
		float sampleRadius = uProjMatrix[2][3] * viewDepth + uProjMatrix[3][3];
		vec2 rad = vec2(uProjMatrix[0][0], uProjMatrix[1][1]) * sss / sampleRadius;
		rad *= 0.5;

		if (dot(rad, rad) < 0.000001)
		{
			gl_FragColor = vec4(lightOrigin, 1.0);
			return;
		}

		// Rotate and offset the progressive disk for each pixel
		vec2 noise = texture2D(uNoiseBuffer, vTexCoord * (uScreenSize / uNoiseSize)).rg;
		float angle = noise.r * TWO_PI;
		vec2 rotation = vec2(cos(angle), sin(angle));
		vec3 lightNew = lightOrigin * uKernel[0].z;
		float totalWeight = uKernel[0].z;
		
		for (int i = 1; i < MAX_SAMPLES; i++)
		{
			if (i >= uSamples)
				break;

			vec2 offset = uKernel[i].xy;
			float radiusSquared = dot(offset, offset);
			float shiftedRadiusSquared = fract(radiusSquared + noise.g);
			offset *= sqrt(shiftedRadiusSquared / max(radiusSquared, 0.000001));
			offset = vec2(offset.x * rotation.x - offset.y * rotation.y,
						  offset.x * rotation.y + offset.y * rotation.x);
			vec2 sampleCoord = vTexCoord + offset * rad;
			float sampleWeight = max(1.0 - shiftedRadiusSquared, 0.05);
			sampleWeight *= sampleWeight;
			totalWeight += sampleWeight;
			
			// Out of bounds?
			if (sampleCoord.x < 0.0 || sampleCoord.x > 1.0 || sampleCoord.y < 0.0 || sampleCoord.y > 1.0)
			{
				lightNew += sampleWeight * lightOrigin;
				continue;
			}
			
			// No neighbouring SSS?
			vec4 sampleRange = texture2D(uSSSRangeBuffer, sampleCoord);
			if ((sampleRange.r + sampleRange.g + sampleRange.b) < 0.001)
			{
				lightNew += sampleWeight * lightOrigin;
				continue;
			}
			
			float sampleDepth = readDepth(sampleCoord);
			if (isDepthBackground(sampleDepth))
			{
				lightNew += sampleWeight * lightOrigin;
				continue;
			}
			
			float sampleViewDepth = uNear + sampleDepth * (uFar - uNear);
			float depthDelta = 1.0 - clamp(abs(viewDepth - sampleViewDepth) / sss, 0.0, 1.0);
			
			// Add mixed light color * sample weight
			lightNew += sampleWeight * mix(lightOrigin, texture2D(uDirect, sampleCoord).rgb, depthDelta * sssRange);
		}

		gl_FragColor = vec4(lightNew / totalWeight, 1.0);
	}
}
