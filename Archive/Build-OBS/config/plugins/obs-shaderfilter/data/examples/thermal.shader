//based on https://www.shadertoy.com/view/mdKXzG

uniform float strength<
    string label = "Strength";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 200.0;
    float step = 0.1;
> = 100.0;

float greyScale(float3 c) {
   	return 0.29 * c.r + 0.60 * c.g + 0.11;
}

float3 heatMap(float greyValue) {   
	float3 heat;      
    heat.r = smoothstep(0.5, 0.8, greyValue);
    if(greyValue >= 0.8333) {
    	heat.r *= (1.1 - greyValue) * 5.0;
    }
	if(greyValue > 0.6) {
		heat.g = smoothstep(1.0, 0.7, greyValue);
	} else {
		heat.g = smoothstep(0.0, 0.7, greyValue);
    }    
	heat.b = smoothstep(1.0, 0.0, greyValue);          
    if(greyValue <= 0.3333) {
    	heat.b *= greyValue / 0.3;     
    }
	return heat;
}

float4 mainImage(VertData v_in) : TARGET
{
    float4 c = image.Sample(textureSampler, v_in.uv);
    float greyValue = greyScale(c.rgb);
    float3 h = heatMap(greyValue*(strength/100.0));
    return float4(h.r, h.g, h.b, c.a);
}