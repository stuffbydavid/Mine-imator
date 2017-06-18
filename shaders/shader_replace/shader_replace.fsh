uniform sampler2D uTexture;
uniform vec4 uReplaceColor;

varying vec2 vTexCoord;

void main()
{
    gl_FragColor = vec4(uReplaceColor.rgb, ceil(texture2D(uTexture, vTexCoord).a));
	
	if (gl_FragColor.a == 0.0)
		discard;
}

