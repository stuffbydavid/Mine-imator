uniform sampler2D uFogBuffer;
uniform vec4 uFogColor;

varying vec2 vTexCoord;

void main()
{
	float fog = texture2D(uFogBuffer, vTexCoord).r;
	gl_FragColor = vec4(uFogColor.rgb, fog);
}
