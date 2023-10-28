#define MAX_SAMPLES 65

varying vec2 vTexCoord;

uniform vec2 uScreenSize;
uniform float uRadius;
uniform vec2 uDirection;

uniform vec2 uKernel[MAX_SAMPLES];
uniform int uSamples;

vec4 getColor(vec2 txcoord)
{
	float xcoord = txcoord.x;
	float ycoord = txcoord.y;

	if(xcoord > 1.0)
		xcoord = 1.0 - (xcoord - 1.0);
		
	if(xcoord < 0.0)
		xcoord = xcoord * -1.0;
		
	if(ycoord > 1.0)
		ycoord = 1.0 - (ycoord - 1.0);
		
	if(ycoord < 0.0)
		ycoord = ycoord * -1.0;

	return texture2D(gm_BaseTexture, vec2(xcoord, ycoord));
}


void main()
{
	vec4 blurResult = vec4(0.0);
	
	vec2 blurAmount = (uRadius / uScreenSize) * uDirection;
	
	// Guassian filter
	for (int i = 0; i < MAX_SAMPLES; i++)
	{
		if (i >= uSamples)
			break;
		
		blurResult += uKernel[i].x * getColor(vTexCoord + (uKernel[i].y * blurAmount));
	}

	gl_FragColor = blurResult;
}