#define MAX_SAMPLES 65

uniform sampler2D uSSSBuffer;
uniform sampler2D uSSSRangeBuffer;
uniform sampler2D uDepthBuffer;
uniform sampler2D uDirect;
uniform sampler2D uNoiseBuffer;

// Camera data
uniform mat4 uProjMatrix;
uniform mat4 uProjMatrixInv;
uniform float uNear;
uniform float uFar;
uniform vec2 uScreenSize;

uniform int uSamples;
uniform float uNoiseSize;
uniform vec2 uKernel[MAX_SAMPLES]; // x = weight, y = distance

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
		vec3 lightNew = lightOrigin * uKernel[0].x;
		
		// Keep blur consistent with pixel depth
		float sampleRadius = uProjMatrix[2][3] * viewDepth + uProjMatrix[3][3];
		vec2 rad = vec2(uProjMatrix[0][0], uProjMatrix[1][1]) * sss / sampleRadius;
		rad *= 0.5;
		
		// Get random direction to blur in
		vec3 noise = texture2D(uNoiseBuffer, vTexCoord * (uScreenSize / uNoiseSize)).rgb;
		vec2 randDir = vec2(cos(noise.r * TWO_PI), sin(noise.r * TWO_PI));
		rad *= noise.g * randDir;
		
		// Sample pixels in positive and negative blur direction
		for (int i = 1; i < MAX_SAMPLES; i++)
		{
			if (i >= uSamples || (abs(rad.x + rad.y) < 0.001))
				break;
			
			vec2 sampleCoord = vTexCoord + (uKernel[i].y * rad);
			vec4 sampleRange = texture2D(uSSSRangeBuffer, sampleCoord);
			
			if (((sampleRange.r + sampleRange.g + sampleRange.b) < 0.001) ||
				((sampleCoord.x < 0.0 || sampleCoord.x > 1.0 || sampleCoord.y < 0.0 || sampleCoord.y > 1.0)) ||
				isDepthBackground(readDepth(sampleCoord)))
			{
				lightNew += uKernel[i].x * lightOrigin;
				continue;
			}
			
			float depthDelta = 1.0 - clamp(abs(viewDepth - getDepth(sampleCoord)) / sss, 0.0, 1.0);
			
			// Add mixed light color * sample weight
			lightNew += uKernel[i].x * mix(lightOrigin, texture2D(uDirect, sampleCoord).rgb, depthDelta * sssRange);
		}
		
		if (abs(rad.x + rad.y) < 0.001)
			gl_FragColor = vec4(lightOrigin, 1.0);
		else
			gl_FragColor = vec4(lightNew, 1.0);		
	}
}
