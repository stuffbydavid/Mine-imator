varying vec2 vTexCoord;

uniform float uResolution;
uniform float uRadius;
uniform vec2 uDirection;

vec4 getColor(vec2 txcoord)
{
	float xcoord = txcoord.x;
	float ycoord = txcoord.y;

	if(xcoord > 1.0)
		xcoord = 1.0 - (xcoord - 1.0);
		
	if(xcoord < 0.0)
		xcoord = xcoord * -1.0;
		
	if(ycoord > 1.0)
		ycoord = 1.0 - (ycoord - 1.0);
		
	if(ycoord < 0.0)
		ycoord = ycoord * -1.0;

	return texture2D(gm_BaseTexture, vec2(xcoord, ycoord));
}


void main()
{
	vec4 blurResult = vec4(0.0);
	
	float blurAmount = uRadius/uResolution; 
	
	float horStep = uDirection.x;
	float verStep = uDirection.y;
    
	// 9-tap guassian filter
    
	blurResult += getColor(vec2(vTexCoord.x - 4.0 * blurAmount * horStep, vTexCoord.y - 4.0 * blurAmount * verStep)) * 0.0162162162;
	blurResult += getColor(vec2(vTexCoord.x - 3.0 * blurAmount * horStep, vTexCoord.y - 3.0 * blurAmount * verStep)) * 0.0540540541;
	blurResult += getColor(vec2(vTexCoord.x - 2.0 * blurAmount * horStep, vTexCoord.y - 2.0 * blurAmount * verStep)) * 0.1216216216;
	blurResult += getColor(vec2(vTexCoord.x - 1.0 * blurAmount * horStep, vTexCoord.y - 1.0 * blurAmount * verStep)) * 0.1945945946;
	
	blurResult += getColor(vec2(vTexCoord.x, vTexCoord.y)) * 0.2270270270;
	
	blurResult += getColor(vec2(vTexCoord.x + 1.0 * blurAmount * horStep, vTexCoord.y + 1.0 * blurAmount * verStep)) * 0.1945945946;
	blurResult += getColor(vec2(vTexCoord.x + 2.0 * blurAmount * horStep, vTexCoord.y + 2.0 * blurAmount * verStep)) * 0.1216216216;
	blurResult += getColor(vec2(vTexCoord.x + 3.0 * blurAmount * horStep, vTexCoord.y + 3.0 * blurAmount * verStep)) * 0.0540540541;
	blurResult += getColor(vec2(vTexCoord.x + 4.0 * blurAmount * horStep, vTexCoord.y + 4.0 * blurAmount * verStep)) * 0.0162162162;

	gl_FragColor = blurResult;
}