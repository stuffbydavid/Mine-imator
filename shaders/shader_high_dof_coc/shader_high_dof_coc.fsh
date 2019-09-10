uniform sampler2D uDepthBuffer;
uniform float uDepth;
uniform float uRange;
uniform float uFadeSize;
uniform float uNear;
uniform float uFar;

varying vec2 vTexCoord;

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

float getDepth(vec2 coord)
{
	return uNear + unpackDepth(texture2D(uDepthBuffer, coord)) * (uFar - uNear);
}

float getFrontBlur(float d)
{
	return clamp(((uDepth - uRange) - d) / uFadeSize, 0.0, 1.0);
}

float getBackBlur(float d)
{
	return clamp((d - (uDepth + uRange)) / uFadeSize, 0.0, 1.0);
}

void main()
{
	float depth = getDepth(vTexCoord);
	float frontBlur = getFrontBlur(depth);
	float backBlur = getBackBlur(depth);
	
	gl_FragColor = vec4(frontBlur, backBlur, 0.0, 1.0);
}
