uniform int corner_radius<
    string label = "Corner radius";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
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
    string label = "Border alpha start";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;
uniform float border_alpha_end<
    string label = "Border alpha end";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.0;
uniform float alpha_cut_off<
    string label = "Aplha cut off";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.5;
uniform bool faster_scan = true;

float4 mainImage(VertData v_in) : TARGET
{
    float4 pixel = image.Sample(textureSampler, v_in.uv);
    int closedEdgeX = 0;
    int closedEdgeY = 0;
    if(pixel.a < alpha_cut_off){
        return float4(1.0,0.0,0.0,0.0);
    }
    float check_dist = corner_radius;
    if(border_thickness > check_dist)
        check_dist = border_thickness;
    if(image.Sample(textureSampler, v_in.uv + float2(check_dist*uv_pixel_interval.x,0)).a < alpha_cut_off){
        closedEdgeX = check_dist;
    }else if(image.Sample(textureSampler, v_in.uv + float2(-check_dist*uv_pixel_interval.x,0)).a < alpha_cut_off){
        closedEdgeX = -check_dist;
    }
    if(image.Sample(textureSampler, v_in.uv + float2(0,check_dist*uv_pixel_interval.y)).a < alpha_cut_off){
        closedEdgeY = check_dist;
    }else if(image.Sample(textureSampler, v_in.uv + float2(0,-check_dist*uv_pixel_interval.y)).a < alpha_cut_off){
        closedEdgeY = -check_dist;
    }
    if(closedEdgeX == 0 && closedEdgeY == 0){
        return pixel;
    }
    if(!faster_scan || closedEdgeX != 0){
        [loop] for(int x = 1;x<check_dist ;x++){
            if(image.Sample(textureSampler, v_in.uv + float2(x*uv_pixel_interval.x, 0)).a < alpha_cut_off){
                closedEdgeX = x;
                break;
            }
            if(image.Sample(textureSampler, v_in.uv + float2(-x*uv_pixel_interval.x, 0)).a < alpha_cut_off){
                closedEdgeX = -x;
                break;
            }
        }
    }
    if(!faster_scan || closedEdgeY != 0){
        [loop] for(int y = 1;y<check_dist;y++){
            if(image.Sample(textureSampler, v_in.uv + float2(0, y*uv_pixel_interval.y)).a < alpha_cut_off){
                closedEdgeY = y;
                break;
            }
            if(image.Sample(textureSampler, v_in.uv + float2(0, -y*uv_pixel_interval.y)).a < alpha_cut_off){
                closedEdgeY = -y;
                break;
            }
        }
    }
    int closedEdgeXabs = closedEdgeX < 0 ? -closedEdgeX : closedEdgeX;
    int closedEdgeYabs = closedEdgeY < 0 ? -closedEdgeY : closedEdgeY;
    if(closedEdgeX == 0){
        if(closedEdgeYabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeYabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            if(border_alpha_start < border_alpha_end){
                pixel.rgb = pixel.rgb * (1.0 - fade_color.a) + fade_color.rgb * fade_color.a;
                pixel.a = border_alpha_end + ((float)closedEdgeYabs / (float)border_thickness)*(pixel.a-border_alpha_end);
                return pixel;
            }
            return fade_color;
        }else{
            return pixel;
        }
    }
    if(closedEdgeY == 0){
        if(closedEdgeXabs <= border_thickness){
            float4 fade_color = border_color;
            fade_color.a = border_alpha_end + ((float)closedEdgeXabs / (float)border_thickness)*(border_alpha_start-border_alpha_end);
            if(border_alpha_start < border_alpha_end){
                pixel.rgb = pixel.rgb * (1.0 - fade_color.a) + fade_color.rgb * fade_color.a;
                pixel.a = border_alpha_end + ((float)closedEdgeXabs / (float)border_thickness)*(pixel.a-border_alpha_end);
                return pixel;
            }
            return fade_color;
        }else{
            return pixel;
        }
    }

    float d = distance(float2(closedEdgeXabs, closedEdgeYabs), float2(check_dist,check_dist));
    if(d > check_dist && border_thickness > corner_radius){
        if(closedEdgeXabs < corner_radius && closedEdgeYabs < corner_radius){
            float cd = distance(float2(closedEdgeXabs, closedEdgeYabs), float2(corner_radius,corner_radius));
            if(floor(cd) > corner_radius)
                return float4(0.0,0.0,0.0,0.0);
            if(cd > corner_radius){
                d = border_thickness + cd - corner_radius;
            } else if(d > border_thickness){
                d = border_thickness;    
            }
        }else if(d > border_thickness){
            d = border_thickness;
        }
    }
    if(floor(d) <= check_dist){
        if(border_thickness > 0){
            if(ceil(check_dist-d) <= border_thickness){
                float4 fade_color = border_color;
                fade_color.a = border_alpha_end + ((check_dist-d)/ (float)border_thickness)*(border_alpha_start-border_alpha_end);
                if(border_alpha_start < border_alpha_end){
                    fade_color.rgb = pixel.rgb * (1.0 - fade_color.a) + fade_color.rgb * fade_color.a;
                    fade_color.a = border_alpha_end + ((check_dist-d) / (float)border_thickness)*(pixel.a-border_alpha_end);
                }
                if(d > check_dist)
                    fade_color.a *= 1.0 -(d - check_dist);
                return fade_color;
            }else if(d >= 0 && floor(check_dist-d) <= border_thickness && border_alpha_start >= border_alpha_end){
                float4 fade_color = border_color;
                float f;
                if(border_thickness > (check_dist-d))
                    f = border_thickness - (check_dist-d);
                else
                    f = 1.0 -((check_dist-d) - border_thickness);
                fade_color.rgb = pixel.rgb * (1.0 - f) + fade_color.rgb * f;
                return fade_color;
            }
        }
        if (d > check_dist)
            pixel.a *= 1.0 - (d - check_dist);
        return pixel;
        
    }
    return float4(0.0,0.0,0.0,0.0);
}