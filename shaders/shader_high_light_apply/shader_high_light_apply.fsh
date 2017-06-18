uniform vec4 uAmbientColor;

varying vec2 vTexCoord;

void main()
{
    vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
    vec4 col = 1.0 - baseColor;
    col *= 1.0 - uAmbientColor;
    gl_FragColor = 1.0 - col;
    gl_FragColor.a = baseColor.a;
}
