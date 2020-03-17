uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;
uniform int uIsSky;
uniform int uIsWater;

uniform vec3 uLightPosition;
uniform vec3 uLightDirection;
uniform vec4 uLightColor;
uniform float uLightStrength;
uniform float uSunNear;
uniform float uSunFar;

uniform sampler2D uDepthBuffer;

uniform int uColoredShadows;
uniform sampler2D uColorBuffer;

uniform float uBleedLight;

varying vec3 vPosition;
varying float vDepth;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying float vBrightness;
varying float vLightBleed;

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0) + c.a / (255.0 * 255.0 * 255.0);
}

void main()
{
	vec3 light;
	
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = texture2D(uTexture, tex);
	
	if (uIsSky > 0)
		light = vec3(1.0);
	else
	{
		// Diffuse factor
		float dif = max(0.0, dot(normalize(vNormal), uLightDirection));	
		dif = clamp(dif + min(1.0, vLightBleed + uBleedLight), 0.0, 1.0);
		
		vec3 shadow = vec3(1.0);
	
		if (dif > 0.0 && vBrightness < 1.0)
		{
			float fragDepth = vScreenCoord.z * .5 + .5;
			vec2 fragCoord = vec2(vScreenCoord.x, -vScreenCoord.y) * .5 + .5;
		
			// Texture position must be valid
			if (fragCoord.x > 0.0 && fragCoord.y > 0.0 && fragDepth > 0.0 && fragCoord.x < 1.0 && fragCoord.y < 1.0 && fragDepth < 1.0)
			{	
				// Calculate bias
				float bias = (1.0 + (.2 * min(1.0, vLightBleed + uBleedLight))) / abs(uSunFar - uSunNear);
				
				// Colored shadows
				if (uColoredShadows > 0)
					if (baseColor.a * uBlendColor.a == 1.0)
						shadow = texture2D(uColorBuffer, fragCoord).rgb;
				
				// Find shadow
				float sampleDepth = unpackDepth(texture2D(uDepthBuffer, fragCoord));
				shadow *= ((fragDepth - bias) > sampleDepth) ? vec3(0.0) : vec3(1.0);
			}
		}
	
		// Calculate light
		if (uIsWater == 1)
			light = uLightColor.rgb * uLightStrength * dif;
		else
			light = uLightColor.rgb * uLightStrength * dif * shadow;
			
		light = mix(light, vec3(1.0), vBrightness);
	}
	
	// Set final color
	gl_FragColor = vec4(light, uBlendColor.a * baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
