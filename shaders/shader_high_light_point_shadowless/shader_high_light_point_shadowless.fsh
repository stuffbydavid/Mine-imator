uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform int uIsSky;

uniform int uLightAmount;
uniform vec4 uLightData[128];
uniform float uBrightness;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vBrightness;
varying float vSSS;

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	vec3 lightResult = vec3(0.0);
	
	if (uIsSky > 0)
		lightResult = vec3(1.0);
	else
		for (int i = 0; i < uLightAmount; i++)
		{
			vec4 data1 = uLightData[i * 2];
			vec4 data2 = uLightData[i * 2 + 1];
			vec3 lightPosition = data1.xyz;
			float lightRange = data1.w, dis, att;
			float lightFadeSize = data2.w;
			
			// No use in shading a pixel if it's not in range
			if (distance(vPosition, lightPosition) > lightRange)
				continue;
			
			// Diffuse factor
			float dif = max(0.0, dot(normalize(vNormal), normalize(lightPosition - vPosition)));
			dif += vSSS;
			
			// Attenuation factor
			dif *= 1.0 - clamp((distance(vPosition, lightPosition) - lightRange * (1.0 - lightFadeSize)) / (lightRange * lightFadeSize), 0.0, 1.0);
		
			// Calculate light
			vec3 light;
			light = data2.rgb * dif;
			light = mix(light, vec3(1.0), vBrightness);
		
			lightResult.rgb += light;
		}
	
	gl_FragColor = vec4(lightResult, baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}

