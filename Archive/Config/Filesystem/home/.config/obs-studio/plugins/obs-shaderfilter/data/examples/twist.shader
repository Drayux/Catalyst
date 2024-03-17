uniform int center_x_percent<
    string label = "center x percentage";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 50;
uniform int center_y_percent<
    string label = "center y percentage";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 50;
uniform float power<
    string label = "power";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 5.0;
    float step = 0.001;
> = 0.3;
uniform float rotation<
    string label = "rotation";
    string widget_type = "slider";
    float minimum = -100.0;
    float maximum = 100.0;
    float step = 0.001;
> = 2.0;

float2x2 rotate(float angle){
    return float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 center_pos = float2(center_x_percent * .01, center_y_percent * .01);
    float d = distance(center_pos,v_in.uv);
    if(d > power){
        return image.Sample(textureSampler, v_in.uv);
    }
    float r = (cos(d*3.14159265359/power) +1)/2 * rotation;
    float2 pos = v_in.uv - center_pos;
    pos = mul(pos, rotate(r));
    pos += center_pos;
    return image.Sample(textureSampler, pos);
}