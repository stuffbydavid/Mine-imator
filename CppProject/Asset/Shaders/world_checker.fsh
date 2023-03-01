uniform vec2 uSize;

varying vec2 vTexCoord;
varying vec4 vColor1;
varying vec4 vColor2;

void main()
{
	float checkerSize = 12;
	vec2 pixel = floor((vTexCoord * uSize) / checkerSize);
	gl_FragColor = mod(pixel.x + mod(pixel.y, 2.0), 2.0) != 0.0 ? vColor1 : vColor2;
}