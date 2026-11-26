uniform sampler2D uSamples;

uniform float uSamplesStrength;
uniform int uRenderBackground;

varying vec2 vTexCoord;

void main()
{
	vec4 result = texture2D(uSamples, vTexCoord) * uSamplesStrength;
	
	if (uRenderBackground > 0)
		result.a = 1.0;
	
	gl_FragColor = result;
}
