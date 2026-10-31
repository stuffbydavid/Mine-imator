uniform int uDepthTest;
uniform sampler2D uDepthBuffer;

varying vec4 vClipPosition;
varying float vDepth;

void main()
{
	if (uDepthTest > 0)
	{
		vec2 uv = vClipPosition.xy / vClipPosition.w * vec2(0.5, -0.5) + 0.5;
		if (vDepth > texture2D(uDepthBuffer, uv).r)
			discard;
	}

	gl_FragColor = vec4(0.0, 0.0, 0.0, 0.4);
}
