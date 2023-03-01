uniform vec4 uColor;
uniform int uBorder;
uniform float uAlpha;

varying vec2 vUv;
varying vec2 vUvScale;
varying float vAlpha;

void main()
{
	gl_FragColor = uColor;

	if (uBorder > 0)
	{
		float borderWidth = 0.05;
		float borderBlurWidth = 0.1;
		float borderTotalWidth = borderWidth + borderBlurWidth;
		vec2 dis = abs(0.5 - vUv) / 0.5;

		vec2 alpha = (dis - (1.0 - vUvScale * borderTotalWidth)) / (vUvScale * borderBlurWidth);
		gl_FragColor.a = clamp(max(alpha.y, alpha.x), 0.0, 1.0 * uAlpha);

		if (gl_FragColor.a < 0.05)
			discard;
	}
	else
		gl_FragColor.a = vAlpha * uAlpha;
}
