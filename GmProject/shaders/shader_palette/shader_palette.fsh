varying vec2 vTexCoord;

uniform sampler2D uPalette;

void main()
{
	vec4 col = texture2D(gm_BaseTexture, vTexCoord);
	col.rgb = texture2D(uPalette, vec2(1.0 - (col.r + 0.00001), 0.001)).rgb;
	gl_FragColor = col;
}
