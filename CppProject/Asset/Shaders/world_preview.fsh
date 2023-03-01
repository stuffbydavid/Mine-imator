uniform sampler2D uTexture;

flat varying vec2 vTexCoord;
varying float vLight;

void main()
{ 
	gl_FragColor = texture2D(uTexture, vTexCoord) * vec4(vLight, vLight, vLight, 1.0);
}
