uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;

uniform sampler2D uTextureMaterial;
uniform vec2 uTexScaleMaterial;

varying vec2 vTexCoord;
varying float vEmissive;

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = uBlendColor * texture2D(uTexture, tex);
	
	// Get material data
	vec2 texMat = vTexCoord;
	if (uTexScaleMaterial.x < 1.0 || uTexScaleMaterial.y < 1.0)
		texMat = mod(texMat * uTexScaleMaterial, uTexScaleMaterial); // GM sprite bug workaround
		
	vec3 mat = texture2D(uTextureMaterial, texMat).rgb;
	
	gl_FragData[0] = vec4(vec3(vEmissive * mat.b), baseColor.a);
	gl_FragData[1] = vec4(vec3(0.0), baseColor.a);
	
	if (baseColor.a == 0.0)
		discard;
}