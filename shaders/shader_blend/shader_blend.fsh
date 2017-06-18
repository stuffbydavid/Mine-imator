uniform sampler2D uTexture;

varying vec2 vTexCoord;
varying vec4 vColor;

void main()
{
    gl_FragColor = vColor * texture2D(uTexture, vTexCoord);
	
	if (gl_FragColor.a == 0.0)
		discard;
}

