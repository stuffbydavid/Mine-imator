uniform vec4 uBox;

varying vec4 vColor;
varying vec2 vTexCoord;
varying vec2 vPosition;

void main()
{
	if (vPosition.x < uBox.x || vPosition.y < uBox.y || vPosition.x > uBox.x + uBox.z || vPosition.y > uBox.y + uBox.w)
		discard;
	
	gl_FragColor = vColor * texture2D(gm_BaseTexture, vTexCoord);
}
