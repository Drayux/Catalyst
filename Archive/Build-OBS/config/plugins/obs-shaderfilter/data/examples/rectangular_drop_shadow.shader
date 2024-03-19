//Converted to OpenGL by Exeldro February 22, 2022
uniform int shadow_offset_x<
    string label = "shadow offset x";
    string widget_type = "slider";
    int minimum = -100;
    int maximum = 100;
    int step = 1;
>;
uniform int shadow_offset_y<
    string label = "shadow offset y";
    string widget_type = "slider";
    int minimum = -100;
    int maximum = 100;
    int step = 1;
>;
uniform int shadow_blur_size<
    string label = "shadow blur size";
    string widget_type = "slider";
    int minimum = 1;
    int maximum = 100;
    int step = 1;
> = 1;

uniform float4 shadow_color;

float4 mainImage(VertData v_in) : TARGET
{
    int shadow_blur_samples = int(pow(shadow_blur_size * 2 + 1, 2));
    
    float4 color = image.Sample(textureSampler, v_in.uv);
    float2 shadow_uv = float2(v_in.uv.x - uv_pixel_interval.x * int(shadow_offset_x), 
                              v_in.uv.y - uv_pixel_interval.y * int(shadow_offset_y));
                              
    float start_of_overlap_x = max(0, shadow_uv.x - shadow_blur_size * uv_pixel_interval.x);
    float end_of_overlap_x = min(1, shadow_uv.x + shadow_blur_size * uv_pixel_interval.x);
    float x_proportion = (end_of_overlap_x - start_of_overlap_x) / (2 * shadow_blur_size * uv_pixel_interval.x);
    
    float start_of_overlap_y = max(0, shadow_uv.y - shadow_blur_size * uv_pixel_interval.y);
    float end_of_overlap_y = min(1, shadow_uv.y + shadow_blur_size * uv_pixel_interval.y);
    float y_proportion = (end_of_overlap_y - start_of_overlap_y) / (2 * shadow_blur_size * uv_pixel_interval.y);
    
    float4 final_shadow_color = float4(shadow_color.r, shadow_color.g, shadow_color.b, shadow_color.a * x_proportion * y_proportion);
    
    return final_shadow_color * (1-color.a) + color;
}
