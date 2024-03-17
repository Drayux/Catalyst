//rounded rectange shader from https://raw.githubusercontent.com/exeldro/obs-lua/master/rounded_rect.shader
//modified slightly by Surn 
uniform int corner_radius<
    string label = "Corner radius";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 200;
    int step = 1;
>;
uniform int border_thickness<
    string label = "Border thickness";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
>;
uniform int minimum_alpha_percent<
    string label = "Minimum alpha percent";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 50;
uniform int rotation_speed<
    string label = "rotation speed";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
>;
uniform float4 border_colorL;
uniform float4 border_colorR;
//uniform float color_spread = 2.0;
uniform int center_width<
    string label = "center width";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 50;
uniform int center_height<
    string label = "center height";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 50;
uniform string notes<
    string widget_type = "info";
> = "Outlines the opaque areas with a rounded border. Default Minimum Alpha Percent is 50%, lowering will reveal more";

// float3 hsv2rgb(float3 c)
// {
//     float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
//     float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
//     return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
// }



float4 gradient(float c) {
    c = c % 2.0;
    if(c < 0.0f){
        c = c * -1.0;
    }
    if(c > 1.0){
        c = 1.0 - c;
        if(c < 0.0f){
            c = c + 1.0;
        }
    }
    return lerp(border_colorL, border_colorR, c);
}

float4 getBorderColor(float2 toCenter){
    float angle = atan2(toCenter.y ,toCenter.x );
	float angleMod = (elapsed_time * rotation_speed % 18) / 9;
	return gradient((angle / 3.14159265f) + angleMod);
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 st = v_in.uv * uv_scale;
    float2 center_pixel_coordinates = float2(((float)center_width * 0.01), ((float)center_height * 0.01) );
    float2 toCenter = center_pixel_coordinates - st;

    float min_alpha = clamp(minimum_alpha_percent * .01, -1.0, 101.0);
    float4 output = image.Sample(textureSampler, v_in.uv);
    if (output.a < min_alpha)
    {
        return float4(0.0, 0.0, 0.0, 0.0);
    }
    int closedEdgeX = 0;
    if (image.Sample(textureSampler, v_in.uv + float2(corner_radius * uv_pixel_interval.x, 0)).a < min_alpha)
    {
        closedEdgeX = corner_radius;
    }
    else if (image.Sample(textureSampler, v_in.uv + float2(-corner_radius * uv_pixel_interval.x, 0)).a < min_alpha)
    {
        closedEdgeX = corner_radius;
    }
    int closedEdgeY = 0;
    if (image.Sample(textureSampler, v_in.uv + float2(0, corner_radius * uv_pixel_interval.y)).a < min_alpha)
    {
        closedEdgeY = corner_radius;
    }
    else if (image.Sample(textureSampler, v_in.uv + float2(0, -corner_radius * uv_pixel_interval.y)).a < min_alpha)
    {
        closedEdgeY = corner_radius;
    }
    if (closedEdgeX == 0 && closedEdgeY == 0)
    {
        return output;
    }
    if (closedEdgeX != 0)
    {
        [loop]
        for (int x = 1; x < corner_radius; x++)
        {
            if (image.Sample(textureSampler, v_in.uv + float2(x * uv_pixel_interval.x, 0)).a < min_alpha)
            {
                closedEdgeX = x;
                break;
            }
            if (image.Sample(textureSampler, v_in.uv + float2(-x * uv_pixel_interval.x, 0)).a < min_alpha)
            {
                closedEdgeX = x;
                break;
            }
        }
    }
    if (closedEdgeY != 0)
    {
        [loop]
        for (int y = 1; y < corner_radius; y++)
        {
            if (image.Sample(textureSampler, v_in.uv + float2(0, y * uv_pixel_interval.y)).a < min_alpha)
            {
                closedEdgeY = y;
                break;
            }
            if (image.Sample(textureSampler, v_in.uv + float2(0, -y * uv_pixel_interval.y)).a < min_alpha)
            {
                closedEdgeY = y;
                break;
            }
        }
    }
    if (closedEdgeX == 0)
    {
        if (closedEdgeY < border_thickness)
        {
            return getBorderColor(toCenter);
        }
        else
        {
            return output;
        }
    }
    if (closedEdgeY == 0)
    {
        if (closedEdgeX < border_thickness)
        {
            return getBorderColor(toCenter);
        }
        else
        {
            return output;
        }
    }

    float d = distance(float2(closedEdgeX, closedEdgeY), float2(corner_radius, corner_radius));
    if (d < corner_radius)
    {
        if (corner_radius - d < border_thickness)
        {
            return getBorderColor(toCenter);
        }
        else
        {
            return output;
        }
    }
    return float4(0.0, 0.0, 0.0, 0.0);
}