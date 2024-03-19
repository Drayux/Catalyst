// Scan Line Effect for OBS Studio
// originally from Andersama (https://github.com/Andersama)
// Modified and improved my Charles Fettinger (https://github.com/Oncorporation)  1/2019
//Converted to OpenGL by Q-mii & Exeldro February 21, 2022
//Count the number of scanlines we want via height or width, adjusts the sin wave period
uniform bool lengthwise;
//Do we want the scanlines to move?
uniform bool animate;
//How fast do we want those scanlines to move?
uniform float speed<
    string label = "Speed";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10000.0;
    float step = 1;
> = 1000;
//What angle should the scanlines come in at (based in degrees)
uniform float angle<
    string label = "angle";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 360.0;
    float step = 0.1;
> = 45;
//Turns on adjustment of the results, sin returns -1 -> 1 these settings will change the results a bit
//By default values for color range from 0 to 1
//Boost centers the result of the sin wave on 1*, to help maintain the brightness of the screen
uniform bool shift = true;
uniform bool boost = true;
//Increases the minimum value of the sin wave
uniform float floor<
    string label = "Floor";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.001;
> = 0.0;
//final adjustment to the period of the sin wave, we can't / 0, need to be careful w/ user input
uniform float period<
    string label = "Period";
    string widget_type = "slider";
    float minimum = 1.0;
    float maximum = 1000.0;
    float step = 1.0;
> = 10.0;
uniform string notes<
    string widget_type = "info";
> = "floor affects the minimum opacity of the scan line";
float4 mainImage(VertData v_in) : TARGET
{
	//3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481 							3.141592653589793238462643383279502884197169399375105820974944592307816406286 
	// float pix2 = 6.2831853071795864769252;//86766559005768394338798750211641949
	 float nfloor = clamp(floor, 0.0, 100.0) * 0.01;
	 float nperiod = max(period, 1.0);
	 float gap = 1 - nfloor;
	 float pi   = 3.1415926535897932384626;
	 float2 direction = float2( cos(angle * pi / 180.0) , sin(angle * pi / 180.0) );
	 float nspeed = 0.0;
	if(animate){
		nspeed = speed * 0.0001;
	}
	
	float4 color = image.Sample(textureSampler, v_in.uv);
	
	float t = elapsed_time * nspeed;
	
	if(!lengthwise){
		 float base_height = 1.0 / uv_pixel_interval.y;
		 float h_interval = pi * base_height;
		
		float rh_sin = sin(((v_in.uv.y * direction.y + v_in.uv.x * direction.x) + t) * (h_interval / nperiod));
		if(shift){
			rh_sin = ((1.0 + rh_sin) * 0.5) * gap + nfloor;
			if(boost){
				rh_sin += gap * 0.5;
			}
		}
		float4 s_mult = float4(rh_sin,rh_sin,rh_sin,1);
		return s_mult * color;
	}
	else{
		 float base_width = 1.0 / uv_pixel_interval.x;
		 float w_interval = pi * base_width;
		
		float rh_sin = sin(((v_in.uv.y * direction.y + v_in.uv.x * direction.x) + t) * (w_interval / nperiod));
		if(shift){
			rh_sin = ((1.0 + rh_sin) * 0.5) * gap + nfloor;
			if(boost){
				rh_sin += gap * 0.5;
			}
		}
		float4 s_mult = float4(rh_sin,rh_sin,rh_sin,1);
		return s_mult * color;
	}
}
