uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;

uniform sampler2D uMaterialTexture;
uniform vec2 uMaterialTexScale;
varying vec2 vTexCoord;
varying float vBrightness;

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = uBlendColor * texture2D(uTexture, tex);
	
	// Get material data
	vec2 matTex = vTexCoord;
	if (uMaterialTexScale.x < 1.0 || uMaterialTexScale.y < 1.0)
		matTex = mod(matTex * uMaterialTexScale, uMaterialTexScale); // GM sprite bug workaround
		
	vec3 mat = texture2D(uMaterialTexture, matTex).rgb;
	
	gl_FragColor = vec4(vec3(vBrightness * mat.b), baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
