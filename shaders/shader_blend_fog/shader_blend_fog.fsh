uniform sampler2D uTexture;

uniform float uFogShow;
uniform vec4 uFogColor;
uniform float uFogDistance;
uniform float uFogSize;
uniform float uFogHeight;

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vDepth;

float getFog()
{
    float fog;
    if (uFogShow > 0.0)
	{
        fog = clamp(1.0 - (uFogDistance - vDepth) / uFogSize, 0.0, 1.0);
        fog *= clamp(1.0 - (vPosition.z - uFogHeight) / uFogSize, 0.0, 1.0);
    }
	else
        fog = 0.0;
	
    return fog;
}

void main()
{
    vec4 baseColor = vColor * texture2D(uTexture, vTexCoord);
    gl_FragColor = mix(baseColor, uFogColor, getFog());
    gl_FragColor.a = baseColor.a;
	
	if (gl_FragColor.a == 0.0)
		discard;
}

