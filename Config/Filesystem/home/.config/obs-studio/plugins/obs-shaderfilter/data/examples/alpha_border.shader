uniform float4 border_color<
    string label = "Border color";
> = {0.0,0.0,0.0,1.0};
uniform int border_thickness<
    string label = "Border thickness";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 0;
uniform float alpha_cut_off<
    string label = "Alpha cut off";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.5;

float4 mainImage(VertData v_in) : TARGET
{
    float4 pix = image.Sample(textureSampler, v_in.uv);
    if (pix.a > alpha_cut_off)
        return pix;
    [loop] for(int x = -border_thickness;x<border_thickness;x++){
            [loop] for(int y = -border_thickness;y<border_thickness;y++){
                if(abs(x*x)+abs(y*y) < border_thickness*border_thickness){
                    float4 t = image.Sample(textureSampler, v_in.uv + float2(x*uv_pixel_interval.x,y*uv_pixel_interval.y));
                    if(t.a > alpha_cut_off)
                        return border_color;
                }
            }
    }
    return pix;
}