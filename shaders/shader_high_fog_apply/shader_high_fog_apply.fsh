uniform sampler2D fogBuffer;
uniform vec4 fogColor;

varying vec2 vTexCoord;

void main()
{
	float fog = texture2D(fogBuffer, vTexCoord).r;
	gl_FragColor = vec4(fogColor.rgb, fog);
}
