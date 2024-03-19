// Frosted Glass shader by Charles Fettinger for obs-shaderfilter plugin 4/2019
//https://github.com/Oncorporation/obs-shaderfilter

uniform float Alpha_Percent<
    string label = "Alpha Percent";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.1;
> = 100.0;
uniform float Amount<
    string label = "Amount";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.03;
uniform float Scale<
    string label = "Scale";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.01;
> = 5.1;
uniform bool Animate;
uniform bool Horizontal_Border;
uniform float Border_Offset<
    string label = "Border Offset";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 2.0;
    float step = 0.01;
> = 1.1;
uniform float4 Border_Color = {.8,.5,1.0,1.0};
uniform string notes<
    string widget_type = "info";
> = "Change shader with Scale and Amount, move Border with Border Offset. Alpha is Opacity of overlay.";

float rand(float2 co)
{
	float scale = Scale;
	if (Animate)
		scale *= rand_f;
	float2 v1 = float2(92.0,80.0);
	float2 v2 = float2(41.0,62.0);
	return frac(sin(dot(co.xy ,v1)) + cos(dot(co.xy ,v2)) * scale);
}

float4 mainImage(VertData v_in) : TARGET
{
	float4 rgba = image.Sample(textureSampler, v_in.uv);
	float3 tc = rgba.rgb * Border_Color.rgb;
	
	float uv_compare = v_in.uv.x;
	if (Horizontal_Border)
		uv_compare = v_in.uv.y;

	if (uv_compare < (Border_Offset - 0.005))
	{
		float2 randv = float2(rand(v_in.uv.yx),rand(v_in.uv.yx));
		tc = image.Sample(textureSampler, v_in.uv + (randv*Amount)).rgb;		
	}
	else if (uv_compare >= (Border_Offset + 0.005))
	{
		tc = image.Sample(textureSampler, v_in.uv).rgb;
	}
	return lerp(rgba,float4(tc,1.0),(Alpha_Percent * 0.01));
}
