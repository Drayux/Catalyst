uniform int Strength<
    string label = "Strength (1)";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 25;
    int step = 1;
> = 1.0;
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
	
    float Pi = 6.28318530718; // Pi*2
       
    float Directions = (float)Strength * 4.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
    float Quality = (float)Strength; // BLUR QUALITY (Default 4.0 - More is better but slower)
    float Size = (float)Strength * (float)Strength; // BLUR SIZE (Radius)
    
    float4 c = image.Sample(textureSampler, v_in.uv);
    float4 oc = c;
    float transparent = oc.a;
    int count = 1.0;
    float samples = oc.a;
    
    // Blur calculations
    [loop] for( float d=0.0; d<Pi; d+=Pi/Directions)
    {
		[loop] for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
        {
            float4 sc = image.Sample(textureSampler,v_in.uv+float2(cos(d),sin(d))*Size*i/uv_size);
            transparent += sc.a;
			count++;
            c += sc * sc.a;
            samples += sc.a;
        }
    }

    //Calculate averages
    if(samples > 0.0)
        c /= samples;

    c.a = transparent / count; 
    return c;
}