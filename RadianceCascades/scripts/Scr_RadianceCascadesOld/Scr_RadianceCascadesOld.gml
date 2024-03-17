function rclight_defaultshaders(width, height) {
	global.rclight_width = width;
	global.rclight_height = height;
	
	global.rclight_jfaseeding = Shd_JumpfloodSeed;
	global.rclight_jumpfloodalgorithm = Shd_JumpfloodAlgorithm;
	global.rclight_distancefield = Shd_DistanceField;
	
	global.rclight_jumpfloodalgorithm_uResolution = shader_get_uniform(global.rclight_jumpfloodalgorithm, "in_Resolution");
	global.rclight_jumpfloodalgorithm_uJumpDistance = shader_get_uniform(global.rclight_jumpfloodalgorithm, "in_JumpDistance");
	global.rclight_distancefield_uResolution = shader_get_uniform(global.rclight_distancefield, "in_Resolution");
}

function rclight_clear(surface) {
    surface_set_target(surface);
    draw_clear_alpha(c_black, 0);
    surface_reset_target();
}

function rclight_jfaseeding(init, jfaA, jfaB) {
    surface_set_target(jfaB);
    draw_clear_alpha(c_black, 0);
    shader_set(global.rclight_jfaseeding);
    draw_surface(init,0,0);
    shader_reset();
    surface_reset_target();
    
    surface_set_target(jfaA);
    draw_clear_alpha(c_black, 0);
    surface_reset_target();
}

function rclight_jfarender(source, destination) {
    var passes = ceil(log2(max(global.rclight_width, global.rclight_height)));
    
    shader_set(global.rclight_jumpfloodalgorithm);
    shader_set_uniform_f(global.rclight_jumpfloodalgorithm_uResolution, global.rclight_width, global.rclight_height);
	
	var tempA = source, tempB = destination, tempC = source;
    var i = 0; repeat(passes) {
        var offset = power(2, passes - i - 1);
        shader_set_uniform_f(global.rclight_jumpfloodalgorithm_uJumpDistance, offset);
        surface_set_target(tempA);
			draw_surface(tempB,0,0);
        surface_reset_target();
		
		tempC = tempA;
		tempA = tempB;
		tempB = tempC;
        i++;
    }
    
    shader_reset();
	if (destination != tempC) {
		surface_set_target(destination);
			draw_surface(tempC,0,0);
        surface_reset_target();
	}
}

function rclight_distancefield(jfa, surface) {
    surface_set_target(surface);
    draw_clear_alpha(c_black, 0);
    shader_set(global.rclight_distancefield);
	shader_set_uniform_f(global.rclight_distancefield_uResolution, global.rclight_width, global.rclight_height);
    draw_surface(jfa, 0, 0);
    shader_reset();
    surface_reset_target();
}