uniform vec2 uScreenSize;
uniform float uPower;

varying vec2 vTexCoord;

vec2 texelSize = 1.0 / uScreenSize;

void main()
{
    float reducemul = 1.0 / 8.0;
    float reducemin = 1.0 / 128.0;
    float def = 4.0;
    
    vec4 basecol = texture2D(gm_BaseTexture, vTexCoord);
    vec4 baseNW = texture2D(gm_BaseTexture, vTexCoord - texelSize);
    vec4 baseNE = texture2D(gm_BaseTexture, vTexCoord + vec2(texelSize.x, -texelSize.y));
    vec4 baseSW = texture2D(gm_BaseTexture, vTexCoord + vec2(-texelSize.x, texelSize.y));
    vec4 baseSE = texture2D(gm_BaseTexture, vTexCoord + texelSize);
    
    vec4 gray = vec4(0.299, 0.587, 0.114, 1.0);
    float monocol = dot(basecol, gray);
    float monoNW = dot(baseNW, gray);
    float monoNE = dot(baseNE, gray);
    float monoSW = dot(baseSW, gray);
    float monoSE = dot(baseSE, gray);
    
    float monomin = min(monocol, min(min(monoNW, monoNE), min(monoSW, monoSE)));
    float monomax = max(monocol, max(max(monoNW, monoNE), max(monoSW, monoSE)));
    
    vec2 dir = vec2(-((monoNW + monoNE) - (monoSW + monoSE)), ((monoNW + monoSW) - (monoNE + monoSE)));
    float dirreduce = max((monoNW + monoNE + monoSW + monoSE) * reducemul * 0.25, reducemin);
    float dirmin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirreduce);
    dir = min(vec2(uPower * def), max(vec2(-uPower * def), dir * dirmin)) * texelSize;
    
    vec4 resultA = 0.5 * (texture2D(gm_BaseTexture, vTexCoord + dir * -0.166667) +
                          texture2D(gm_BaseTexture, vTexCoord + dir * 0.166667));
    vec4 resultB = resultA * 0.5 + 0.25 * (texture2D(gm_BaseTexture, vTexCoord + dir * -0.5) +
                                           texture2D(gm_BaseTexture, vTexCoord + dir * 0.5));
    float monoB = dot(resultB, gray);
    
    if (monoB < monomin || monoB > monomax)
        gl_FragColor = resultA;
    else
        gl_FragColor = resultB;
}
