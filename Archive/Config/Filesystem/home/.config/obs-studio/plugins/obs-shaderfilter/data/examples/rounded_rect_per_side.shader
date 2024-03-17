uniform int corner_radius_bottom<
    string label = "Corner radius bottom";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 200;
    int step = 1;
>;
uniform int corner_radius_left<
    string label = "Corner radius left";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 200;
    int step = 1;
>;
uniform int corner_radius_top<
    string label = "Corner radius top";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 200;
    int step = 1;
>;
uniform int corner_radius_right<
    string label = "Corner radius right";
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
uniform float4 border_color;
uniform float border_alpha_start<
    string label = "border alpha start";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 1.0;
uniform float border_alpha_end<
    string label = "border alpha end";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.0;
uniform float alpha_cut_off<
    string label = "alpha cut off";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.5;

float4 mainImage(VertData v_in) : TARGET
{
    float4 output = image.Sample(textureSampler, v_in.uv);
    int closedEdgeX = 0;
    int closedEdgeY = 0;
    if(output.a < alpha_cut_off){
        return float4(1.0,0.0,0.0,0.0);
    }
    if(image.Sample(textureSampler, v_in.uv + float2(corner_radius_right*uv_pixel_interval.x,0)).a < alpha_cut_off){
        closedEdgeX = corner_radius_right;
    }else if(image.Sample(textureSampler, v_in.uv + float2(-corner_radius_left*uv_pixel_interval.x,0)).a < alpha_cut_off){
        closedEdgeX = -corner_radius_left;
    }
    if(image.Sample(textureSampler, v_in.uv + float2(0,corner_radius_bottom*uv_pixel_interval.y)).a < alpha_cut_off){
        closedEdgeY = corner_radius_bottom;
    }else if(image.Sample(textureSampler, v_in.uv + float2(0,-corner_radius_top*uv_pixel_interval.y)).a < alpha_cut_off){
        closedEdgeY = -corner_radius_top;
    }
    if(closedEdgeX == 0 && closedEdgeY == 0){
        return output;
    }
    if(closedEdgeX != 0){
        [loop] for(int x = 1;x<corner_radius_right;x++){
            if(image.Sample(textureSampler, v_in.uv + float2(x*uv_pixel_interval.x, 0)).a < alpha_cut_off){
                closedEdgeX = x;
                break;
            }
        }
        [loop] for(int x = 1;x<corner_radius_left;x++){
            if(image.Sample(textureSampler, v_in.uv + float2(-x*uv_pixel_interval.x, 0)).a < alpha_cut_off){
                closedEdgeX = -x;
                break;
            }
        }
    }
    if(closedEdgeY != 0){
        [loop] for(int y = 1;y<corner_radius_bottom;y++){
            if(image.Sample(textureSampler, v_in.uv + float2(0, y*uv_pixel_interval.y)).a < alpha_cut_off){
                closedEdgeY = y;
                break;
            }
        }
        [loop] for(int y = 1;y<corner_radius_top;y++){
            if(image.Sample(textureSampler, v_in.uv + float2(0, -y*uv_pixel_interval.y)).a < alpha_cut_off){
                closedEdgeY = -y;
                break;
            }
        }
    }
    int closedEdgeXabs = closedEdgeX < 0 ? -closedEdgeX : closedEdgeX;
    int closedEdgeYabs = closedEdgeY < 0 ? -closedEdgeY : closedEdgeY;
    float corner_radius_x = closedEdgeX < 0? corner_radius_left: corner_radius_right;
    float corner_radius_y = closedEdgeY < 0 ? corner_radius_top:corner_radius_bottom;
    float corner_radius = corner_radius_x < corner_radius_y ? corner_radius_x : corner_radius_y;
    if(closedEdgeXabs > corner_radius){
        closedEdgeXabs = 0;
    }
    if(closedEdgeYabs > corner_radius){
        closedEdgeYabs = 0;
    }
    if(closedEdgeXabs == 0 && closedEdgeYabs == 0){
        return output;
    }
    if(closedEdgeXabs == 0){
        if(closedEdgeYabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeYabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return output;
        }
    }
    if(closedEdgeYabs == 0){
        if(closedEdgeXabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeXabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return output;
        }
    }

    float closest = closedEdgeXabs<closedEdgeYabs?closedEdgeXabs:closedEdgeYabs;
    float d = distance(float2(closedEdgeXabs, closedEdgeYabs), float2(corner_radius,corner_radius));
    if(d<corner_radius){
        if(corner_radius-d <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((corner_radius-d)/ (float)border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return output;
        }
    }
    return float4(0.0,0.0,0.0,0.0);
}