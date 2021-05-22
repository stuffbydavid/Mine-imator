uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;
uniform int uIsSky;
uniform int uIsWater;

uniform vec3 uLightPosition;
uniform vec4 uLightColor;
uniform float uLightStrength;
uniform float uLightNear;
uniform float uLightFar;
uniform float uLightFadeSize;
uniform float uLightSpotSharpness;
uniform vec3 uShadowPosition;

uniform sampler2D uDepthBuffer;

uniform float uSSS;
uniform vec3 uSSSRadius;
uniform vec4 uSSSColor;
uniform float uMetallic;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec4 vScreenCoord;
varying vec4 vShadowCoord;
varying float vBrightness;
varying float vBlockSSS;

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

void main() 
{
	vec3 light;
	int sssEnabled = (vBlockSSS + uSSS > 0.0 ? 1 : 0);
	
	if (uIsSky > 0)
		light = vec3(1.0);
	else
	{
		float dif = 0.0;
		float difMask = 0.0;
		float shadow = 1.0;
		float att = 0.0;
		vec3 subsurf = vec3(0.0);
		
		// Check if not behind the spot light
		if (vScreenCoord.w > 0.0)
		{
			// Diffuse factor
			dif = max(0.0, dot(normalize(vNormal), normalize(uLightPosition - vPosition)));
			
			// Attenuation factor
			att = 1.0 - clamp((distance(vPosition, uLightPosition) - uLightFar * (1.0 - uLightFadeSize)) / (uLightFar * uLightFadeSize), 0.0, 1.0);
			dif *= att;
			
			// Material
			dif *= 1.0 - uMetallic;
			
			if ((dif > 0.0 && vBrightness < 1.0) || sssEnabled > 0)
			{
				// Spotlight circle
				float fragDepth = min(vScreenCoord.z, uLightFar);
				vec2 fragCoord = (vec2(vScreenCoord.x, -vScreenCoord.y) / vScreenCoord.z + 1.0) * 0.5;
				
				// Texture position must be valid
				if (fragCoord.x > 0.0 && fragCoord.y > 0.0 && fragCoord.x < 1.0 && fragCoord.y < 1.0)
				{
					// Create circle
					difMask = 1.0 - clamp((distance(fragCoord, vec2(0.5, 0.5)) - 0.5 * uLightSpotSharpness) / (0.5 * max(0.01, 1.0 - uLightSpotSharpness)), 0.0, 1.0);
				} 
				else
					difMask = 0.0;
				
				dif *= difMask;
				
				// Calculate shadow
				fragDepth = min(vShadowCoord.z, uLightFar);
				fragCoord = (vec2(vShadowCoord.x, -vShadowCoord.y) / vShadowCoord.z + 1.0) * 0.5;
				
				if (difMask > 0.0)
				{
					// Calculate bias
					float bias = 1.0;
					
					// Shadow
					float sampleDepth = uLightNear + unpackDepth(texture2D(uDepthBuffer, fragCoord)) * (uLightFar - uLightNear);
					shadow = ((fragDepth - bias) > sampleDepth) ? 0.0 : 1.0;
					
					// Get subsurface translucency
					vec3 dis = vec3(uSSSRadius * max(uSSS, vBlockSSS));
					float lightdis = (fragDepth + bias) - sampleDepth;
					
					subsurf = vec3(vec3(1.0) - clamp(vec3(lightdis) / dis, vec3(0.0), vec3(1.0)));
					subsurf *= att;
				}
			}
		}
		
		// Translucency
		float transDif = max(0.0, dot(normalize(-vNormal), normalize(uLightPosition - vPosition)));
		transDif = clamp(transDif, 0.0, 1.0);
		subsurf *= (uLightColor.rgb * uLightStrength * uSSSColor.rgb * transDif);
		
		// Disable translucency on diffuse
		subsurf *= (dif > 0.0 ? 0.0 : 1.0);
		
		// Calculate light
		if (uIsWater == 1)
			light = uLightColor.rgb * uLightStrength * dif;
		else
			light = uLightColor.rgb * uLightStrength * dif * shadow;
		
		light += subsurf * difMask;
		light *= mix(vec3(1.0), uSSSColor.rgb, clamp(uSSS/16.0, 0.0, 1.0));
		
		light = mix(light, vec3(1.0), vBrightness);
	}
		
	// Set final color
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = texture2D(uTexture, tex);
	gl_FragColor = vec4(light, uBlendColor.a * baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
