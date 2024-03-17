uniform int center_x_percent<
    string label = "center x percent";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 50;
uniform int center_y_percent<
    string label = "center y percent";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 50;
uniform float power<
    string label = "power";
    string widget_type = "slider";
    float minimum = 0;
    float maximum = 20.0;
    float step = 0.001;
> = 1.75;

float4 mainImage(VertData v_in) : TARGET
{
    float2 center_pos = float2(center_x_percent * .01, center_y_percent * .01);
    float2 uv = v_in.uv;
    uv.x = (v_in.uv.x - center_pos.x) * power +  center_pos.x;
    uv.y = (v_in.uv.y - center_pos.y) * power +  center_pos.y;
    return image.Sample(textureSampler, uv);
}