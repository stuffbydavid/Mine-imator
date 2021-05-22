#define MAX_SAMPLES 65

uniform sampler2D uSSSBuffer;
uniform sampler2D uSSSRangeBuffer;
uniform sampler2D uSSSColorBuffer;
uniform sampler2D uDepthBuffer;
uniform sampler2D uNoiseBuffer;
uniform sampler2D uDirect;
uniform sampler2D uIndirect;

// Camera data
uniform mat4 uProjMatrix;
uniform mat4 uProjMatrixInv;
uniform float uNear;
uniform float uFar;
uniform vec2 uScreenSize;

uniform int uSamples;
uniform vec2 uDirection;
uniform vec2 uKernel[MAX_SAMPLES];
uniform int useIndirect;
uniform float uJitterThreshold;

varying vec2 vTexCoord;

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

float getDepth(vec2 coord)
{
	return uNear + unpackDepth(texture2D(uDepthBuffer, coord)) * (uFar - uNear);
}

vec3 getLight(vec2 coord)
{
	vec3 color;
	
	if (useIndirect == 1)
		color = texture2D(uDirect, coord).rgb + texture2D(uIndirect, coord).rgb;
	else
		color = texture2D(uDirect, coord).rgb;
	
	return color;
}

void main()
{
	float originDepth = unpackDepth(texture2D(uDepthBuffer, vTexCoord));
	float viewDepth = getDepth(vTexCoord);
	vec3 originLight = getLight(vTexCoord);
	vec3 sssRange = texture2D(uSSSRangeBuffer, vTexCoord).rgb;
	float sss = (unpackDepth(texture2D(uSSSBuffer, vTexCoord)) * 256.0);
	
	// idk how this works but it keeps the blur consistant with camera distance
	float sampleRadius = uProjMatrix[2][3] * viewDepth + uProjMatrix[3][3];
	vec2 rad = vec2(uProjMatrix[0][0], uProjMatrix[1][1]) * sss / sampleRadius;
	rad *= 0.5;
	
	vec3 color = getLight(vTexCoord) * uKernel[0].x;
	
	float noise = texture2D(uNoiseBuffer, vTexCoord * (uScreenSize/64.0)).r;
	vec2 randDir = vec2(cos(noise), sin(noise));
	
	// Guassian blur
	for (int i = 1; i < MAX_SAMPLES; i++)
	{
		if (i >= uSamples || rad == 0.0)
			break;
		
		vec2 offset = (abs(uKernel[i].y) < uJitterThreshold ? randDir : uDirection) * uKernel[i].y * rad;
		
		vec2 sampleCoord  = vTexCoord + offset;
		vec3 sampleLight  = getLight(sampleCoord);
		float sampleDepth = getDepth(sampleCoord);
		
		float depthDelta = 1.0 - clamp(abs(viewDepth - sampleDepth) / sss, 0.0, 1.0);
		
		vec3 lightMix = depthDelta * sssRange;
		
		if (sampleCoord.x < 0.0 || sampleCoord.x > 1.0 || sampleCoord.y < 0.0 || sampleCoord.y > 1.0)
			lightMix = vec3(0.0);
		
		if (texture2D(uDepthBuffer, sampleCoord).a == 0.0)
			lightMix = vec3(0.0);
		
		color += uKernel[i].x * mix(originLight, sampleLight, lightMix);
	}
	
	if (rad == 0.0)
		gl_FragColor = vec4(originLight, 1.0);
	else
		gl_FragColor = vec4(color, 1.0);
}
