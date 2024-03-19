//Converted to OpenGl by Q-mii & Exeldro February 21, 2022
uniform int corner_radius<
    string label = "Corner radius";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 200;
    int step = 1;
>;
uniform int border_thickness<
    string label = "border thickness";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
>;

uniform float4 border_color;

float4 mainImage(VertData v_in) : TARGET
{
    float2 mirrored_tex_coord = float2(0.5, 0.5) - abs(v_in.uv - float2(0.5, 0.5));
    float4 output_color = image.Sample(textureSampler, v_in.uv);
    
    float2 pixel_position = float2(mirrored_tex_coord.x / uv_pixel_interval.x, mirrored_tex_coord.y / uv_pixel_interval.y);
    float pixel_distance_from_center = distance(pixel_position, float2(corner_radius, corner_radius));
    
    bool is_in_corner = pixel_position.x < corner_radius && pixel_position.y < corner_radius;
    bool is_within_radius = pixel_distance_from_center <= corner_radius;
    
    bool is_within_edge_border = !is_in_corner && (pixel_position.x < 0 && pixel_position.x >= -border_thickness || pixel_position.y < 0 && pixel_position.y >= -border_thickness);
    bool is_within_corner_border = is_in_corner && pixel_distance_from_center > corner_radius && pixel_distance_from_center <= (corner_radius + border_thickness);
    
    return ((!is_in_corner || is_within_radius)?output_color:float4(0,0,0,0)) + ((is_within_edge_border || is_within_corner_border)?border_color:float4(0,0,0,0));
}
