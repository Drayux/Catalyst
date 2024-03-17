uniform float strength<
	string label = "Strength";
	string widget_type = "slider";
	float minimum = 0.;
	float maximum = 200.;
	float step = 0.01;
> = 33.33;

uniform float4 border<
	string label = "Border Color";
> = {0., 0., 0., 1.};

uniform float feathering<
	string label = "Feathering";	
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 100.0;
	float step = 0.01;
> = 33.33;


float4 mainImage(VertData v_in) : TARGET
{
    float2 cc = v_in.uv - float2(0.5, 0.5);
    float dist = dot(cc, cc) * strength / 100.0;
    float2 bent = v_in.uv + cc * (1.0 + dist) * dist;
    if ((bent.x <= 0.0 || bent.x >= 1.0) || (bent.y <= 0.0 || bent.y >= 1.0)) {
		return border;
	}
    if (feathering >= .01) {
        float2 borderArea = float2(0.5, 0.5) * feathering / 100.0;
        float2 borderDistance = (float2(0.5, 0.5) - abs(bent - float2(0.5, 0.5))) / float2(0.5, 0.5);
        borderDistance = (min(borderDistance - float2(0.5, 0.5) * feathering / 100.0, 0) + borderArea) / borderArea;
        float borderFade = sin(borderDistance.x * 1.570796326) * sin(borderDistance.y * 1.570796326);
        return lerp(border, image.Sample(textureSampler, bent), borderFade);
    }

	return image.Sample(textureSampler, bent);
}
