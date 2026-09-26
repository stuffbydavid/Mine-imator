uniform vec2 uScreenSize;
uniform vec2 uPixelCheck;

varying vec2 vTexCoord;

void main()
{
	vec2 texelCheck = uPixelCheck / uScreenSize;
	vec2 coc = texture2D(gm_BaseTexture, vTexCoord).rg;
	float frontBlur = coc.r * 0.07038609;
	float maxFront = coc.r;
	vec2 pair;

	pair = vec2(texture2D(gm_BaseTexture, vTexCoord + texelCheck * 2.0).r,
	            texture2D(gm_BaseTexture, vTexCoord - texelCheck * 2.0).r);
	frontBlur += (pair.x + pair.y) * 0.06930323;
	maxFront = max(maxFront, max(pair.x, pair.y));
	pair = vec2(texture2D(gm_BaseTexture, vTexCoord + texelCheck * 4.0).r,
	            texture2D(gm_BaseTexture, vTexCoord - texelCheck * 4.0).r);
	frontBlur += (pair.x + pair.y) * 0.06615308;
	maxFront = max(maxFront, max(pair.x, pair.y));
	pair = vec2(texture2D(gm_BaseTexture, vTexCoord + texelCheck * 6.0).r,
	            texture2D(gm_BaseTexture, vTexCoord - texelCheck * 6.0).r);
	frontBlur += (pair.x + pair.y) * 0.06121629;
	maxFront = max(maxFront, max(pair.x, pair.y));
	pair = vec2(texture2D(gm_BaseTexture, vTexCoord + texelCheck * 8.0).r,
	            texture2D(gm_BaseTexture, vTexCoord - texelCheck * 8.0).r);
	frontBlur += (pair.x + pair.y) * 0.05491461;
	maxFront = max(maxFront, max(pair.x, pair.y));
	pair = vec2(texture2D(gm_BaseTexture, vTexCoord + texelCheck * 10.91472868).r,
	            texture2D(gm_BaseTexture, vTexCoord - texelCheck * 10.91472868).r);
	frontBlur += (pair.x + pair.y) * 0.08799981;
	maxFront = max(maxFront, max(pair.x, pair.y));
	pair = vec2(texture2D(gm_BaseTexture, vTexCoord + texelCheck * 14.88372093).r,
	            texture2D(gm_BaseTexture, vTexCoord - texelCheck * 14.88372093).r);
	frontBlur += (pair.x + pair.y) * 0.05890754;
	maxFront = max(maxFront, max(pair.x, pair.y));
	pair = vec2(texture2D(gm_BaseTexture, vTexCoord + texelCheck * 19.59193357).r,
	            texture2D(gm_BaseTexture, vTexCoord - texelCheck * 19.59193357).r);
	frontBlur += (pair.x + pair.y) * 0.04549326;
	maxFront = max(maxFront, max(pair.x, pair.y));
	pair = vec2(texture2D(gm_BaseTexture, vTexCoord + texelCheck * 27.20180397).r,
	            texture2D(gm_BaseTexture, vTexCoord - texelCheck * 27.20180397).r);
	frontBlur += (pair.x + pair.y) * 0.02081914;
	maxFront = max(maxFront, max(pair.x, pair.y));

	frontBlur += max(frontBlur - coc.r, 0.0) * 0.8;
	gl_FragColor = vec4(min(max(frontBlur, coc.r), maxFront), coc.g, 0.0, 1.0);
}
