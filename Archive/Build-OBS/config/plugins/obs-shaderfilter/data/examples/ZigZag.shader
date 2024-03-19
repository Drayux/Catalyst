//Created by Radegast Stravinsky for obs-shaderfilter 9/2020
uniform float radius<
    string label = "radius";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 5.0;
    float step = 0.001;
> = 0.0;
uniform float angle<
    string label = "angle";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 360.0;
    float step = 0.1;
> = 180.0;
uniform float period<
    string label = "period";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 5.0;
    float step = 0.001;
> = 0.5;
uniform float amplitude<
    string label = "amplitude";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 5.0;
    float step = 0.001;
> = 1.0;

uniform float center_x<
    string label = "center x";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.5;
    float step = 0.001;
> = 0.25;
uniform float center_y<
    string label = "center y";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.5;
    float step = 0.001;
> = 0.25;

uniform float phase<
    string label = "phase";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 5.0;
    float step = 0.001;
> = 1.0;
uniform int animate<
  string label = "animate";
  string widget_type = "select";
  int    option_0_value = 0;
  string option_0_label = "No";
  int    option_1_value = 1;
  string option_1_label = "Amplitude";
  int    option_2_value = 2;
  string option_2_label = "Time";
> = 0;


uniform string notes = "Distorts the screen, creating a rippling effect that moves clockwise and anticlockwise."


float4 mainImage(VertData v_in) : TARGET
{
    float2 center = float2(center_x, center_y);
	VertData v_out;
    v_out.pos = v_in.pos;
    float2 hw = uv_size;
    float ar = 1. * hw.y/hw.x;

    v_out.uv = 1. * v_in.uv - center;
    
    center.x /= ar;
    v_out.uv.x /= ar;
    
    float dist = distance(v_out.uv, center);
    if (dist < radius)
    {
        float percent = (radius-dist)/radius;
        float theta = percent * percent * 
        (
            animate == 1 ? 
                amplitude * sin(elapsed_time) : 
                amplitude
        ) 
        * sin(percent * percent / period * radians(angle) + (phase + 
        (
            animate == 2 ? 
            elapsed_time : 
            0
        )));

        float s =  sin(theta);
        float c = cos(theta);
        v_out.uv = float2(dot(v_out.uv-center, float2(c,-s)), dot(v_out.uv-center, float2(s,c)));
        v_out.uv += (2 * center);
        
        v_out.uv.x *= ar;

        return image.Sample(textureSampler, v_out.uv);
    }
    else
    {
        return image.Sample(textureSampler, v_in.uv);
    }
        
}