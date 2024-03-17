// opacity blend shader by Charles Fettinger for obs-shaderfilter plugin 3/2019
//https://github.com/Oncorporation/obs-shaderfilter
//Converted to OpenGL by Exeldro February 14, 2022
uniform bool Vertical;
uniform bool Rotational;
uniform float Rotation_Offset<
    string label = "Rotation Offset";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 6.28318531;
    float step = 0.01;
> = 0.0;
uniform float Opacity_Start_Percent<
    string label = "Opacity Start Percent";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 1.0;
> = 0.0;
uniform float Opacity_End_Percent<
    string label = "Opacity End Percent";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 1.0;
> = 100.0;
uniform float Spread<
    string label = "Spread";
    string widget_type = "slider";
    float minimum = 0.25;
    float maximum = 10.0;
    float step = 0.01;
> = 0.5;
uniform float Speed<
    string label = "Speed";
    string widget_type = "slider";
    float minimum = -10.0;
    float maximum = 10.0;
    float step = 0.01;
> = 0.0;
uniform bool Apply_To_Alpha_Layer = true;
uniform string Notes<
    string widget_type = "info";
> = "Spread is wideness of opacity blend and is limited between .25 and 10. Edit at your own risk. Invert Start and End to Reverse effect.";

float4 mainImage(VertData v_in) : TARGET
{
	float4 point_color = image.Sample(textureSampler, v_in.uv);
	float luminance = 0.299*point_color.r+0.587*point_color.g+0.114*point_color.b;
	float4 gray = float4(luminance,luminance,luminance, 1);

	float2 lPos = (v_in.uv * uv_scale + uv_offset) / clamp(Spread, 0.25, 10.0);
	float time = (elapsed_time * clamp(Speed, -5.0, 5.0)) / clamp(Spread, 0.25, 10.0);
	float dist = distance(v_in.uv , (float2(0.99, 0.99) * uv_scale + uv_offset));

	if (point_color.a > 0.0 || Apply_To_Alpha_Layer == false)
	{
		//set opacity and direction
		float opacity = (-1 * lPos.x) * 0.5;

		if (Rotational && (Vertical == false))
		{
			float timeWithOffset = time + Rotation_Offset;
			float sine = sin(timeWithOffset);
			float cosine = cos(timeWithOffset);
			opacity = (lPos.x * cosine + lPos.y * sine) * 0.5;
		}

		if (Vertical && (Rotational == false))
		{
			opacity = (-1 * lPos.y) * 0.5;
		}

		opacity += time;
		opacity = frac(opacity);
		point_color.a = lerp(Opacity_Start_Percent * 0.01, Opacity_End_Percent * 0.01, clamp(opacity, 0.0, 1.0));
	}
	return point_color;
}


