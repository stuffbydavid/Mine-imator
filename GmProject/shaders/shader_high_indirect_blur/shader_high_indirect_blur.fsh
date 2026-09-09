#define SAMPLES 27
#define KERNEL_RADIUS 4.5

varying vec2 vTexCoord;

uniform sampler2D uDepthBuffer;
uniform sampler2D uNormalBuffer;
uniform sampler2D uNoiseBuffer;
uniform vec2 uScreenSize;
uniform vec2 uPixelCheck;

uniform float uNoiseSize;
uniform float uSamples;
uniform float uBlurSize;

#pragma shady: inline(common_util.DEPTH_BUFFER_LIB)
#pragma shady: inline(common_util.DEPTH_RECONSTRUCT_LIB)
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)
#pragma shady: inline(common_util.NEIGHBOR_FILTER_LIB)
#pragma shady: inline(common_constants.MATH)

void main()
{
	vec2 texelSize = 1.0 / uScreenSize;
	vec2 blurScale = texelSize * KERNEL_RADIUS * (uBlurSize / KERNEL_RADIUS);
	
	float centerDepth = readDepth(vTexCoord);
	if (isDepthBackground(centerDepth))
		discard;
	
	vec3 centerNormal = unpackNormal(texture2D(uNormalBuffer, vTexCoord));
	vec3 centerPos = posFromBuffer(vTexCoord, centerDepth);
	
	// Generate random direction
	float theta, cosTheta, sinTheta;
	theta = texture2D(uNoiseBuffer, vTexCoord * (uScreenSize / uNoiseSize)).r * TWO_PI;
	cosTheta = cos(theta);
	sinTheta = sin(theta);
	
	vec2 taps[SAMPLES];
	taps[0] = vec2(-0.8835609, 2.523391);
	taps[1] = vec2(-1.387375, 1.056318);
	taps[2] = vec2(-2.854452, 1.313645);
	taps[3] = vec2(0.6326182, 1.14569);
	taps[4] = vec2(1.331515, 3.637297);
	taps[5] = vec2(-2.175307, 3.885795);
	taps[6] = vec2(-0.5396664, 4.1938);
	taps[7] = vec2(-0.6708734, -0.36875);
	taps[8] = vec2(-2.083908, -0.6921188);
	taps[9] = vec2(-3.219028, 2.85465);
	taps[10] = vec2(-1.863933, -2.742254);
	taps[11] = vec2(-4.125739, -1.283028);
	taps[12] = vec2(-3.376766, -2.81844);
	taps[13] = vec2(-3.974553, 0.5459405);
	taps[14] = vec2(3.102514, 1.717692);
	taps[15] = vec2(2.951887, 3.186624);
	taps[16] = vec2(1.33941, -0.166395);
	taps[17] = vec2(2.814727, -0.3216669);
	taps[18] = vec2(0.7786853, -2.235639);
	taps[19] = vec2(-0.7396695, -1.702466);
	taps[20] = vec2(0.4621856, -3.62525);
	taps[21] = vec2(4.181541, 0.5883132);
	taps[22] = vec2(4.22244, -1.11029);
	taps[23] = vec2(2.116917, -1.789436);
	taps[24] = vec2(1.915774, -3.425885);
	taps[25] = vec2(3.142686, -2.656329);
	taps[26] = vec2(-1.108632, -4.023479);
	
	float weight = 1.0;
	vec3 color = texture2D(gm_BaseTexture, vTexCoord).rgb;
	
	for (int i = 0; i < SAMPLES; i++)
	{
		vec2 tap = taps[i];
		vec2 samplePos = vec2(tap.x * cosTheta - tap.y * sinTheta,
								tap.x * sinTheta + tap.y * cosTheta);
		
		samplePos = vTexCoord + samplePos * blurScale;
		
		float sampleWeight = getNeighborSurfaceWeight(samplePos, centerPos, centerNormal);
		if (sampleWeight < 0.001)
			continue;
		
		color += texture2D(gm_BaseTexture, samplePos).rgb * sampleWeight;
		weight += sampleWeight;
	}
	
	color /= weight;
	
	gl_FragColor = vec4(color, 1.0);
}
