// RGB Color Wheel shader by Charles Fettinger for obs-shaderfilter plugin 5/2020
// https://github.com/Oncorporation/obs-shaderfilter
//Converted to OpenGl by Q-mii & Exeldro February 25, 2022
uniform float speed<
    string label = "Speed";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 15.0;
    float step = 0.1;
> = 2.0;
uniform float color_depth<
    string label = "Color Depth";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.1;
> = 2.10;
uniform bool Apply_To_Image;
uniform bool Replace_Image_Color;
uniform bool Apply_To_Specific_Color;
uniform float4 Color_To_Replace;
uniform float Alpha_Percentage<
    string label = "Alpha Percentage";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.1;
> = 100; //<Range(0.0,100.0)>
uniform int center_width_percentage<
    string label = "center width percentage";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 50;
uniform int center_height_percentage<
    string label = "center height percentage";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 50;

float3 hsv2rgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

float mod(float x, float y)
{
	return x - y * floor(x / y);
}

float4 mainImage(VertData v_in) : TARGET
{
	const float PI = 3.14159265f;//acos(-1);
	float PI180th = 0.0174532925; //PI divided by 180
	float4 rgba = image.Sample(textureSampler, v_in.uv);
	float2 center_pixel_coordinates = float2((center_width_percentage * 0.01), (center_height_percentage * 0.01) );
	float2 st = v_in.uv* uv_scale;
	float2 toCenter = center_pixel_coordinates - st ;
	float r = length(toCenter) * color_depth;
	float angle = atan2(toCenter.y ,toCenter.x );
	float angleMod = (elapsed_time * mod(speed ,18)) / 18;

	rgba.rgb = hsv2rgb(float3((angle / PI*0.5) + angleMod,r,1.0));

    float4 color;
    float4 original_color;
	if (Apply_To_Image)
	{
		color = image.Sample(textureSampler, v_in.uv);
		original_color = color;
		float luma = color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
		if (Replace_Image_Color)
			color = float4(luma, luma, luma, luma);
		rgba = lerp(original_color, rgba * color,clamp(Alpha_Percentage *.01 ,0,1.0));
		
	}
    if (Apply_To_Specific_Color)
    {
        color = image.Sample(textureSampler, v_in.uv);
        original_color = color;
        color = (distance(color.rgb, Color_To_Replace.rgb) <= 0.075) ? rgba : color;
        rgba = lerp(original_color, color, clamp(Alpha_Percentage * .01, 0, 1.0));
    }

	return rgba;
}