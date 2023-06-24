varying vec2 vTexCoord;

uniform sampler2D uPalette;
uniform sampler2D uPaletteKey;
uniform float uPaletteSize;

void main()
{
	vec4 col = texture2D(gm_BaseTexture, vTexCoord);
	int checks = int(min(64.0, uPaletteSize));
	for (int i = 0; i <= checks; i++)
	{
		float u = clamp(1.0 - ((float(i) / uPaletteSize)), 0.01, 0.99);
		vec3 keyCol = texture2D(uPaletteKey, vec2(u, 0.001)).rgb;
		
		if (keyCol.r == col.r && keyCol.g == col.g && keyCol.b == col.b)
			col.rgb = texture2D(uPalette, vec2(u, 0.001)).rgb;
	}
	
	gl_FragColor = col;
}
