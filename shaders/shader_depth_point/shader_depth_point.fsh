uniform sampler2D uTexture;
uniform vec3 uEye;
uniform float uNear;
uniform float uFar;

varying vec3 vPosition;
varying vec2 vTexCoord;

vec4 packDepth(float f)
{
     return vec4(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0), 1.0);
}

void main()
{
    if (texture2D(uTexture, vTexCoord).a == 0.0)
        discard;
    
    gl_FragColor = packDepth((distance(vPosition, uEye) - uNear) / (uFar - uNear));
}

