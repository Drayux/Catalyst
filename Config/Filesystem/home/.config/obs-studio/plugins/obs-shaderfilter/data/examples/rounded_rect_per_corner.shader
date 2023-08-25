//Converted to OpenGL by Q-mii & Exeldro February 18, 2022
uniform int corner_radius_tl<
    string label = "Corner radius top left";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 200;
    int step = 1;
>;
uniform int corner_radius_tr<
    string label = "Corner radius top right";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 200;
    int step = 1;
>;
uniform int corner_radius_br<
    string label = "Corner radius bottom right";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 200;
    int step = 1;
>;
uniform int corner_radius_bl<
    string label = "Corner radius bottom left";
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
    float4 pixel = image.Sample(textureSampler, v_in.uv);
    int closedEdgeX = 0;
    int closedEdgeY = 0;
    if(pixel.a < alpha_cut_off){
        return float4(1.0,0.0,0.0,0.0);
    }
    int corner_radius_top = corner_radius_tl>corner_radius_tr?corner_radius_tl:corner_radius_tr;
    int corner_radius_right = corner_radius_tr>corner_radius_br?corner_radius_tr:corner_radius_br;
    int corner_radius_bottom = corner_radius_bl>corner_radius_br?corner_radius_bl:corner_radius_br;
    int corner_radius_left = corner_radius_tl>corner_radius_bl?corner_radius_tl:corner_radius_bl;
    
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
        return pixel;
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
    int corner_radius = 0;
    if(closedEdgeX < 0 && closedEdgeY < 0){
        corner_radius = corner_radius_tl;
    }else if(closedEdgeX > 0 && closedEdgeY < 0){
        corner_radius = corner_radius_tr;
    }else if(closedEdgeX > 0 && closedEdgeY > 0){
        corner_radius = corner_radius_br;
    }else if(closedEdgeX < 0 && closedEdgeY > 0){
        corner_radius = corner_radius_bl;
    }
    if(closedEdgeXabs > corner_radius && closedEdgeYabs > corner_radius){
        return pixel;
    }
    if(closedEdgeXabs == 0){
        if(closedEdgeYabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + (closedEdgeYabs / border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    if(closedEdgeYabs == 0){
        if(closedEdgeXabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + (closedEdgeXabs / border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    if(closedEdgeXabs > corner_radius){
        if(closedEdgeYabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + (closedEdgeYabs / border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    if(closedEdgeYabs > corner_radius){
        if(closedEdgeXabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + (closedEdgeXabs / border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    float d = distance(float2(closedEdgeXabs, closedEdgeYabs), float2(corner_radius,corner_radius));
    if(d<corner_radius){
        if(corner_radius-d <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((corner_radius-d)/ border_thickness)*(border_alpha_start-border_alpha_end);
            return fade_color;
        }else{
            return pixel;
        }
    }
    return float4(0.0,0.0,0.0,0.0);
}