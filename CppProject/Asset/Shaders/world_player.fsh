uniform sampler2D uTexture; // static

varying vec2 vTexCoord;

void main()
{
	gl_FragColor = texture2D(uTexture, vTexCoord);
}
