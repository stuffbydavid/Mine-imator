uniform sampler2D uTexture;

uniform int uMask;

varying vec2 vTexCoord;
varying vec4 vColor;

void main()
{
	vec2 tex = vTexCoord;
	vec4 color;
	color = texture2D(uTexture, tex);
	
	if (uMask > 0)
	{
		color.a = color.r;
		color.rgb = vColor.rgb;
	}
	else
		color *= vColor;
	
	gl_FragColor = color;
}