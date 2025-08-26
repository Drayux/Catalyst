// Glass shader by Charles Fettinger for obs-shaderfilter plugin 4/2019
//https://github.com/Oncorporation/obs-shaderfilter
//Converted to OpenGl by Q-mii & Exeldro February 25, 2022
uniform float Alpha_Percent<
    string label = "Alpha Percent";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.1;
> = 100.0;
uniform float Offset_Amount<
    string label = "Offset Amount";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.01;
> = 0.8;
uniform int xSize<
    string label = "x Size";
    string widget_type = "slider";
    int minimum = 1;
    int maximum = 100;
    int step = 1;
> = 8;
uniform int ySize<
    string label = "y Size";
    string widget_type = "slider";
    int minimum = 1;
    int maximum = 100;
    int step = 1;
> = 8;
uniform int Reflection_Offset<
    string label = "Reflection Offset";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 2;
uniform bool Horizontal_Border;
uniform float Border_Offset<
    string label = "Border Offset";
    string widget_type = "slider";
    float minimum = -0.01;
    float maximum = 1.01;
    float step = 0.01;
> = 0.5;
uniform float4 Border_Color = {.8,.5,1.0,1.0};
uniform float4 Glass_Color;
uniform string notes<
    string widget_type = "info";
> = "xSize, ySize are for distortion. Offset Amount and Reflection Offset change glass properties. Alpha is Opacity of overlay.";

float mod(float a, float b){
	float d = a / b;
	return (d-floor(d))*b;
}

float4 mainImage(VertData v_in) : TARGET
{
	

	int xSubPixel = int(mod((v_in.uv.x * uv_size.x) , float(clamp(xSize,1,100))));
	int ySubPixel = int(mod((v_in.uv.y * uv_size.y) , float(clamp(ySize,1,100))));
	float2 offsets = float2(Offset_Amount * xSubPixel / uv_size.x, Offset_Amount * ySubPixel / uv_size.y);
	float2 uv = v_in.uv + offsets;
	float2 uv2 = float2(uv.x + (Reflection_Offset / uv_size.x),uv.y + (Reflection_Offset / uv_size.y));

	float4 rgba = image.Sample(textureSampler, v_in.uv);
	float4 rgba_output = float4(rgba.rgb * Border_Color.rgb, rgba.a);
	rgba = image.Sample(textureSampler, uv);
	float4 rgba_glass = image.Sample(textureSampler, uv2);
	
	float uv_compare = v_in.uv.x;
	if (Horizontal_Border)
		uv_compare = v_in.uv.y;

	if (uv_compare < (Border_Offset - 0.005))
	{
			rgba_output = (rgba + rgba_glass) *.5 * Glass_Color;
	}
	else if (uv_compare >= (Border_Offset + 0.005))
	{
		rgba_output = image.Sample(textureSampler, v_in.uv);
	}
	return lerp(rgba,rgba_output,(Alpha_Percent * 0.01));
}
