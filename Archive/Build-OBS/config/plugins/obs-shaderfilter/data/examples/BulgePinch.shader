//Created by Radegast Stravinsky for obs-shaderfilter 9/2020
uniform float radius<
    string label = "Radius";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 2.0;
    float step = 0.01;
> = 0.0;
uniform float magnitude<
    string label = "Magnitude";
    string widget_type = "slider";
    float minimum = -1.3333;
    float maximum = 1.3333;
    float step = 0.01;
> = 0.0;
uniform float center_x<
    string label = "Center x";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.5;
    float step = 0.01;
> = 0.25;
uniform float center_y<
    string label = "Center y";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.5;
    float step = 0.01;
> = 0.25;
uniform bool animate = false;

uniform string notes<
    string widget_type = "info";
> = "Distorts the screen, expanding or drawing in pixels around a point."


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
        float anim_mag = (animate ? magnitude * sin(radians(elapsed_time * 20)) : magnitude);
        float percent = dist/radius;
        if(anim_mag > 0)
            v_out.uv = (v_out.uv - center) * lerp(1.0, smoothstep(0.0, radius/dist, percent), anim_mag * 0.75);
        else
            v_out.uv = (v_out.uv-center) * lerp(1.0, pow(percent, 1.0 + anim_mag * 0.75) * radius/dist, 1.0 - percent);

        v_out.uv += (2 * center);
        v_out.uv.x *= ar;

        return image.Sample(textureSampler, v_out.uv);
    }
    else
    {
        return image.Sample(textureSampler, v_in.uv);
    }
}