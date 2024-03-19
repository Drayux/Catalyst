uniform float distance_factor<
    string label = "distance factor";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.001;
> = 12.0;
uniform float time_factor<
    string label = "time factor";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.001;
> = 2.0;
uniform float power_factor<
    string label = "power factor";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.001;
> = 3.0;
uniform float center_pos_x<
    string label = "center pos x";
    string widget_type = "slider";
    float minimum = -1.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.0;
uniform float center_pos_y<
    string label = "center pos y";
    string widget_type = "slider";
    float minimum = -1.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.0;

float4 mainImage(VertData v_in) : TARGET
{
    float2 cPos = (v_in.uv * 2 ) -1;
    float2 center_pos = float2(center_pos_x, center_pos_y);
    float cLength = distance(cPos, center_pos);
	float2 uv = v_in.uv+(cPos/cLength)*cos(cLength*distance_factor-elapsed_time*time_factor) * power_factor / 100.0;
    return image.Sample(textureSampler, uv);
}