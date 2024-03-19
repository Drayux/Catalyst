//based on https://www.shadertoy.com/view/tscfWM
uniform float colorDepth<
    string label = "Color depth";
    string widget_type = "slider";
    float minimum = 0.01;
    float maximum = 100.0;
    float step = 0.01;
> = 5.0;

uniform float pixelSize<
    string label = "Pixel Size";
    string widget_type = "slider";
    float minimum = 1.0;
    float maximum = 100.0;
    float step = 0.01;
> = 5.0; 


float4 mainImage(VertData v_in) : TARGET
{
    // Change these to change results
    float2 size = uv_size / pixelSize;
    float2 uv = v_in.uv;
    // Maps UV onto grid of variable size to pixilate the image
    uv = round(uv*size)/size;
    float4 col = image.Sample(textureSampler, uv);
    // Maps color onto the specified color depth
    return float4(round(col.r * colorDepth) / colorDepth, 
                    round(col.g * colorDepth) / colorDepth,
                    round(col.b * colorDepth) / colorDepth, 1.0);
}