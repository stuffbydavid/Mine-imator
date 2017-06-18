uniform sampler2D uTexture;

varying vec2 vTexCoord;
varying vec4 vColor;

void main()
{
    vec4 baseColor = vColor * texture2D(uTexture, vTexCoord);
    if (baseColor.a >= 1.0)
        discard;
    
    gl_FragColor = baseColor;
}

