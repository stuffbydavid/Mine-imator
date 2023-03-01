varying vec2 vUv;
varying vec4 vColor;

void main()
{
	gl_FragColor = vColor * texture2D(gm_BaseTexture, vUv);
}
