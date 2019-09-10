#define SAMPLES 4

uniform vec2 uScreenSize;
uniform vec2 uPixelCheck;

varying vec2 vTexCoord;

void main()
{
	// Turn the pixel into a texel
	vec2 texelCheck = (uPixelCheck / uScreenSize) * 2.0;
	
	// Set up weights
	float weights[SAMPLES + 1];
	weights[0] = 70.0;
	weights[1] = 56.0;
	weights[2] = 28.0;
	weights[3] = 8.0;
	weights[4] = 1.0;
	
	// Back blur(R) can't bleed into focus, while the front blur(G) can
	float myFrontBlur = texture2D(gm_BaseTexture, vTexCoord).r;
	float myBackBlur = texture2D(gm_BaseTexture, vTexCoord).g;
	float frontBlur = myFrontBlur * weights[0];
	float totalFrontWeight = weights[0];
	
	// Sample surrounding pixels
	for (int i = 0; i < SAMPLES; i += 1)
	{
		// Get the sample uv coordinates
		vec2 sampleOffset = float(i + 1) * texelCheck;
		
		// Positive direction
		vec2 sampleCoords = vTexCoord + sampleOffset;
		
		float weight = weights[i + 1];
		frontBlur += texture2D(gm_BaseTexture, sampleCoords).r * weight;
		totalFrontWeight += weight;
		
		// Negative direction
		sampleCoords = vTexCoord - sampleOffset;
		
		frontBlur += texture2D(gm_BaseTexture, sampleCoords).r * weight;
		totalFrontWeight += weight;
	}
	
	gl_FragColor = vec4(max(frontBlur / totalFrontWeight, myFrontBlur), myBackBlur, 0.0, 1.0);
}
