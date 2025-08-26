uniform float left_side_width<
    string label = "Left side width";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.1;
uniform float left_side_size<
    string label = "Left side size";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.9;
uniform float left_side_shadow<
    string label = "Left side shadow";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.8;
uniform float left_flip_width<
    string label = "Left flip width";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.05;
uniform float left_flip_shadow<
    string label = "Left flip shadow";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.6;

uniform float right_side_width<
    string label = "Right side width";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.1;
uniform float right_side_size<
    string label = "Right side size";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.9;
uniform float right_side_shadow<
    string label = "Right side shadow";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.8;
uniform float right_flip_width<
    string label = "Right flip width";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.05;
uniform float right_flip_shadow<
    string label = "Right flip shadow";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.6;

float4 mainImage(VertData v_in) : TARGET
{
    float2 pos=v_in.uv;
    float shadow = 1.0;
    if(pos.x < left_side_width){
        pos.y -= 0.5;
        pos.y /= left_side_size;
        pos.y += 0.5;
        pos.x -= left_side_width + left_flip_width / 2.0;
        pos.x /= left_side_size;
        pos.x += left_side_width + left_flip_width / 2.0;
        shadow = left_side_shadow;
    }else if(pos.x < left_side_width + left_flip_width){
        float factor = 1.0 - ((left_side_width + left_flip_width)-pos.x)/left_flip_width*(1.0 - left_side_size);
        pos.y -= 0.5;
        pos.y /= factor;
        pos.y += 0.5;
        pos.x -= left_side_width + left_flip_width;
        pos.x /= factor;
        pos.x += left_side_width + left_flip_width;
        shadow = left_flip_shadow;
    }

    if(1.0 - pos.x < right_side_width){
        pos.y -= 0.5;
        pos.y /= right_side_size;
        pos.y += 0.5;
        pos.x -= 1.0 - (right_side_width + right_flip_width / 2.0);
        pos.x /= right_side_size;
        pos.x += 1.0 - (right_side_width + right_flip_width / 2.0);
        shadow = right_side_shadow;
    }else if(1.0 - pos.x < right_side_width + right_flip_width){
        float factor = 1.0 - ((right_side_width + right_flip_width) - (1.0 - pos.x))/right_flip_width*(1.0 - right_side_size);
        pos.y -= 0.5;
        pos.y /= factor;
        pos.y += 0.5;
        pos.x -= 1.0 - (right_side_width + right_flip_width);
        pos.x /= factor;
        pos.x += 1.0 -(right_side_width + right_flip_width);
        shadow = right_flip_shadow;
    }
    float4 p_color = image.Sample(textureSampler, pos);
    p_color.rgb *= shadow;
    return p_color;
}