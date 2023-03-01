uniform sampler2D uTexture; // static
uniform vec4 uReplaceColor;

varying vec2 vTexCoord;

void main()
{
	vec2 tex = vTexCoord;
	gl_FragColor = vec4(uReplaceColor.rgb, ceil(texture2D(uTexture, tex).a));
	
	if (gl_FragColor.a == 0.0)
		discard;
}

