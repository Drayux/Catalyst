uniform float inner_radius<
    string label = "inner radius";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.1;
> = 32.0;
uniform float outer_radius<
    string label = "outer radius";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.1;
> = 50.0;
uniform float start_angle<
    string label = "Start angle";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 360.0;
    float step = 0.1;
> = 90.0;

uniform int total<
    string label = "Total";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 100;
uniform int part_1<
    string label = "Part 1";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 50;
uniform float4 color_1 = {0.0,0.26,0.62,1.0};
uniform int part_2<
    string label = "Part 2";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 25;
uniform float4 color_2 = {0.24,0.40,0.68,1.0};
uniform int part_3<
    string label = "Part 3";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 10;
uniform float4 color_3 = {0.38,0.56,0.75,1.0};
uniform int part_4<
    string label = "Part 4";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 5;
uniform float4 color_4 = {0.52,0.72,0.81,1.0};
uniform int part_5<
    string label = "Part 5";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 3;
uniform float4 color_5 = {0.69,0.87,0.86,1.0};
uniform int part_6<
    string label = "Part 6";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 2;
uniform float4 color_6 = {1.0,0.79,0.73,1.0};
uniform int part_7<
    string label = "Part 7";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 1;
uniform float4 color_7 = {0.99,0.57,0.57,1.0};
uniform int part_8<
    string label = "Part 8";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 1;
uniform float4 color_8 = {0.91,0.36,0.44,1.0};
uniform int part_9<
    string label = "Part 9";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 1;
uniform float4 color_9 = {0.77,0.16,0.32,1.0};
uniform int part_10<
    string label = "Part 10";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 1000;
    int step = 1;
> = 0;
uniform float4 color_10 = {0.58,0.0,0.23,1.0};

float4 mainImage(VertData v_in) : TARGET
{
    const float pi = 3.14159265358979323846;
    float parts[] = {part_1, part_2, part_3, part_4, part_5, part_6, part_7, part_8, part_9, part_10};
    float4 colors[] = {color_1, color_2, color_3, color_4, color_5, color_6, color_7, color_8, color_9, color_10};
    float2 center = float2(0.5, 0.5);
    float2 factor;
    if(uv_size.x < uv_size.y){
        factor = float2(1.0, uv_size.y/uv_size.x);
    }else{
        factor = float2(uv_size.x/uv_size.y, 1.0);
    }
    center = center * factor;
    float d = distance(center, v_in.uv * factor);
    if(d > outer_radius/100.0 || d < inner_radius/100.0){
        return image.Sample(textureSampler, v_in.uv);
    }
    float2 toCenter = center - v_in.uv*factor;
    float angle = atan2(toCenter.y ,toCenter.x);
    angle = angle - (start_angle / 180.0 * pi);
    if(angle < 0.0) 
        angle = pi + pi + angle;
    if(angle < 0.0) 
        angle = pi + pi + angle;
    angle = angle / (pi + pi);
    float t = 0.0;
    for(int i = 0; i < 10; i+=1) {
        float part = parts[i]/total;
        if(angle > t && angle <= t+part){
            return colors[i];
        }
        t = t + part;
    }
    return image.Sample(textureSampler, v_in.uv);
}