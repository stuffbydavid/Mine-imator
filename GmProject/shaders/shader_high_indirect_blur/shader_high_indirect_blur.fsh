#define DEPTH_SENSITIVITY 120.0
#define SAMPLES 27
#define KERNEL_RADIUS 4.5

const vec2 TAPS[SAMPLES] = vec2[SAMPLES](
	vec2(-0.8835609, 2.523391),
	vec2(-1.387375, 1.056318),
	vec2(-2.854452, 1.313645),
	vec2(0.6326182, 1.14569),
	vec2(1.331515, 3.637297),
	vec2(-2.175307, 3.885795),
	vec2(-0.5396664, 4.1938),
	vec2(-0.6708734, -0.36875),
	vec2(-2.083908, -0.6921188),
	vec2(-3.219028, 2.85465),
	vec2(-1.863933, -2.742254),
	vec2(-4.125739, -1.283028),
	vec2(-3.376766, -2.81844),
	vec2(-3.974553, 0.5459405),
	vec2(3.102514, 1.717692),
	vec2(2.951887, 3.186624),
	vec2(1.33941, -0.166395),
	vec2(2.814727, -0.3216669),
	vec2(0.7786853, -2.235639),
	vec2(-0.7396695, -1.702466),
	vec2(0.4621856, -3.62525),
	vec2(4.181541, 0.5883132),
	vec2(4.22244, -1.11029),
	vec2(2.116917, -1.789436),
	vec2(1.915774, -3.425885),
	vec2(3.142686, -2.656329),
	vec2(-1.108632, -4.023479)
);

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
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)
#pragma shady: inline(common_constants.MATH)

void main()
{
	vec2 texelSize = 1.0 / uScreenSize;
	vec2 blurScale = texelSize * (12.0 / (1.0 + min(uSamples / 8.0, 12.0))) * (uBlurSize / KERNEL_RADIUS);
	
	float centerDepth = readDepth(vTexCoord);
	vec3 centerNormal = unpackNormal(texture2D(uNormalBuffer, vTexCoord));
	
	// Generate random direction
	float theta, cosTheta, sinTheta;
	theta = texture2D(uNoiseBuffer, vTexCoord * (uScreenSize / uNoiseSize)).r * TWO_PI;
	cosTheta = cos(theta);
	sinTheta = sin(theta);
	
	float weight = 1.0;
	vec3 color = texture2D(gm_BaseTexture, vTexCoord).rgb;
	
	for (int i = 0; i < SAMPLES; i++)
	{
		vec2 tap = TAPS[i];
		vec2 samplePos = vec2(tap.x * cosTheta - tap.y * sinTheta,
							  tap.x * sinTheta + tap.y * cosTheta);
		
		samplePos = vTexCoord + samplePos * blurScale;
		
		if (samplePos.x < 0.0 || samplePos.x > 1.0 || samplePos.y < 0.0 || samplePos.y > 1.0)
			continue;
		
		vec3 sampleNormal = unpackNormal(texture2D(uNormalBuffer, samplePos));
		float sampleDepth = readDepth(samplePos);
		
		float sampleWeight = max(0.0, dot(centerNormal, sampleNormal) - abs(sampleDepth - centerDepth) * DEPTH_SENSITIVITY);
		color += texture2D(gm_BaseTexture, samplePos).rgb * sampleWeight;
		weight += sampleWeight;
	}
	
	color /= weight;
	
	gl_FragColor = vec4(color, 1.0);
}
