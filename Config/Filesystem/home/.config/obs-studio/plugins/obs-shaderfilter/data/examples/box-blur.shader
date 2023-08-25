uniform int Strength<
    string label = "Strength (1)";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 25;
    int step = 1;
> = 1;
uniform float Mask_Left<
    string label = "Mask left (1.0)";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;
uniform float Mask_Right<
    string label = "Mask right (1.0)";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;
uniform float Mask_Top<
    string label = "Mask top (1.0)";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;
uniform float Mask_Bottom<
    string label = "Mask bottom (1.0)";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;

float4 mainImage(VertData v_in) : TARGET
{
    if(Strength <= 0)
        return image.Sample(textureSampler, v_in.uv);
	
	if(Mask_Left + Mask_Right > 1.0){
		if(v_in.uv.x > Mask_Left || 1.0 - v_in.uv.x > Mask_Right ){
			return image.Sample(textureSampler, v_in.uv);
		}
	}else{
		if((v_in.uv.x > Mask_Left) && (1.0-v_in.uv.x > Mask_Right)){
			return image.Sample(textureSampler, v_in.uv);
		}
	}
	if(Mask_Top + Mask_Bottom > 1.0){
		if(v_in.uv.y > Mask_Top || 1.0 - v_in.uv.y > Mask_Bottom){
			return image.Sample(textureSampler, v_in.uv);
		}
	}else {
		if((v_in.uv.y > Mask_Top) && (1.0-v_in.uv.y > Mask_Bottom)){
			return image.Sample(textureSampler, v_in.uv);
		}
	}
    float transparent = 0.0;
    int count = 1.0;
    float samples = 0.0;
    float4 c = float4(0.0, 0.0, 0.0, 0.0);
    float Steps = (float)Strength;
    
    [loop] for (int i = -Strength; i <= Strength; i++) {
    	[loop] for (int k = -Strength; k <= Strength; k++) {
            float4 sc = image.Sample(textureSampler, v_in.uv+float2(i, k)/uv_size*Steps);
            transparent += sc.a;
			count++;
            c += sc * sc.a;
            samples += sc.a;
        }
    }
    if(samples > 0.0)
        c /= samples;

    c.a = transparent / count; 
    return c;
}