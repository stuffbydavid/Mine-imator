uniform sampler2D uTexture; // static
uniform vec4 uReplaceColor;

uniform float uSampleIndex;
uniform int uAlphaHash;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying vec4 vColor;

float hash(vec2 c)
{
	return fract(10000.0 * sin(17.0 * c.x + 0.1 * c.y) *
	(0.1 + abs(sin(13.0 * c.y + c.x))));
}

void main()
{
	vec2 tex = vTexCoord;
	vec4 basecolor = texture2D(uTexture, tex) * vColor;
	gl_FragColor = vec4(uReplaceColor.rgb, basecolor.a);
	
	if (uAlphaHash > 0)
	{
		if (gl_FragColor.a < hash(vec2(hash(vPosition.xy + (uSampleIndex / 255.0)), vPosition.z + (uSampleIndex / 255.0))))
			discard;
		else
			gl_FragColor.a = 1.0;
	}
	
	if (gl_FragColor.a == 0.0)
		discard;
}

