//based on https://www.shadertoy.com/view/ldjGzV
//Converted to OpenGL by Exeldro February 19, 2022
uniform float vertical_shift<
    string label = "vertical shift";
    string widget_type = "slider";
    float minimum = -5.0;
    float maximum = 5.0;
    float step = 0.001;
> = 0.4;
uniform float distort<
    string label = "distort";
    string widget_type = "slider";
    float minimum = 0;
    float maximum = 5.0;
    float step = 0.001;
> = 1.2;
uniform float vignet<
    string label = "vignet";
    string widget_type = "slider";
    float minimum = -5.0;
    float maximum = 5.0;
    float step = 0.001;
> = 1.0;
uniform float stripe<
    string label = "stripe";
    string widget_type = "slider";
    float minimum = -5.0;
    float maximum = 5.0;
    float step = 0.001;
> = 1.0;
uniform float vertical_factor<
    string label = "vertical factor";
    string widget_type = "slider";
    float minimum = -5.0;
    float maximum = 5.0;
    float step = 0.001;
> = 1.0;
uniform float vertical_height<
    string label = "vertical height";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1000.0;
    float step = 0.1;
> = 30.0;

float onOff(float a, float b, float c)
{
	return step(c, sin(elapsed_time + a*cos(elapsed_time*b)));
}

float ramp(float y, float start, float end)
{
	float inside = step(start,y) - step(end,y);
	float fact = (y-start)/(end-start)*inside;
	return (1.-fact) * inside;
	
}

float modu(float x, float y)
{
	return (x / y) - floor(x / y);
}

float stripes(float2 uv)
{
	return ramp(modu(uv.y*4. + elapsed_time/2.+sin(elapsed_time + sin(elapsed_time*0.63)),1.),0.5,0.6)*stripe;
}

float4 getVideo(float2 uv)
{
	float2 look = uv;
	float window = 1./(1.+20.*(look.y-modu(elapsed_time/4.,1.))*(look.y-modu(elapsed_time/4.,1.)));
	look.x = look.x + sin(look.y*10. + elapsed_time)/50.*onOff(4.,4.,.3)*(1.+cos(elapsed_time*80.))*window;
	float vShift = vertical_shift*onOff(2.,3.,.9)*(sin(elapsed_time)*sin(elapsed_time*20.) + 
										 (0.5 + 0.1*sin(elapsed_time*200.)*cos(elapsed_time)));
	look.y = modu((look.y + vShift) , 1.);
    return image.Sample(textureSampler, look);
}

float2 screenDistort(float2 uv)
{
	uv -= float2(.5,.5);
	uv = uv*distort*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
	uv += float2(.5,.5);
	return uv;
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 uv = v_in.uv;
    uv = screenDistort(uv);
	float4 video = getVideo(uv);
    float vigAmt = 3.+.3*sin(elapsed_time + 5.*cos(elapsed_time*5.));
	float vignette = ((1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5))-1.)*vignet+1.;
    video += stripes(uv);
    video *= vignette;
	video *= (((12.+modu((uv.y*vertical_height+elapsed_time),1.))/13.)-1.)*vertical_factor+1.;
    return float4(video.r, video.g, video.b ,1.0);
}
