uniform sampler2D uTexture;

uniform int uMask;
uniform int uClipEnabled;
uniform vec4 uClipBox;

varying vec2 vTexCoord;
varying vec4 vColor;
varying vec2 vPosition;

void main()
{
	if (uClipEnabled > 0 && (vPosition.x < uClipBox.x || vPosition.y < uClipBox.y || vPosition.x > uClipBox.x + uClipBox.z || vPosition.y > uClipBox.y + uClipBox.w))
		discard;

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
