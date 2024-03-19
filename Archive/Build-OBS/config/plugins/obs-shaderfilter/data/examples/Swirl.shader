//Created by Radegast Stravinsky for obs-shaderfilter 9/2020
uniform float radius<
    string label = "Radius";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.5; //<Range(0.0, 1.0)>
uniform float angle<
    string label = "Angle";
    string widget_type = "slider";
    float minimum = -360.0;
    float maximum = 360.0;
    float step = 0.01;
> = 270.0; //<Range(-1800.0, 1800.0)>

uniform float center_x<
    string label = "Center x";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.5;
    float step = 0.001;
> = 0.25; //<Range(0.0, 1.0)>
uniform float center_y<
    string label = "Center y";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.5;
    float step = 0.001;
> = 0.25; //<Range(0.0, 1.0)>

uniform bool animate = false;
uniform bool inverse = false;

uniform string notes<
    string widget_type = "info";
> = "Distorts the screen, twisting the image in a circular motion."

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
        float percent = (radius-dist)/(radius);
        percent = inverse == 0 ? percent : 1 - percent;

        float theta = percent * percent * radians(angle * (animate == true ? sin(elapsed_time) : 1.0));
        float s =  sin(theta);
        float c =  cos(theta);
        v_out.uv = float2(dot(v_out.uv-center, float2(c,-s)), dot(v_out.uv-center, float2(s,c)));
        v_out.uv += (2 * center);
        
        v_out.uv.x *= ar;

        return image.Sample(textureSampler, v_out.uv);
    }
    else
    {
        return image.Sample(textureSampler, v_in.uv );
    }
        
}
