// Disable blending for all Global Illumination render processes (we don't care about alpha components here).
gpu_set_blendenable(false);

	// Generate the JFA + SDF of the world scene.
	rclight_jfaseeding(gameworld_worldscene, gameworld_temporary, gameworld_jumpflood);
	rclight_jfarender(gameworld_temporary, gameworld_jumpflood);
	rclight_distancefield(gameworld_jumpflood, gameworld_distancefield);
	
	var rclight_ucascade_resolution = shader_get_uniform(Shd_RadianceIntervalsOld, "in_CascadeResolution");
	var rclight_uradiance_interval  = shader_get_uniform(Shd_RadianceIntervalsOld, "in_RadianceInterval");
	var rclight_ucascade_scaling    = shader_get_uniform(Shd_RadianceIntervalsOld, "in_CascadeScaling");
	var rclight_ucascade_index      = shader_get_uniform(Shd_RadianceIntervalsOld, "in_CascadeIndex");
	
	var rclight_uresolution         = shader_get_uniform(Shd_RadianceIntervalsOld, "in_Resolution");
	var rclight_uworldscene         = shader_get_sampler_index(Shd_RadianceIntervalsOld, "in_WorldScene");
	var rclight_udistancefield      = shader_get_sampler_index(Shd_RadianceIntervalsOld, "in_DistanceField");
	
	for(var i = 0; i < global.rc_cascade_count; i++) {
		shader_set(Shd_RadianceIntervalsOld);
		shader_set_uniform_f(rclight_ucascade_resolution, global.rc_cascade_width, global.rc_cascade_height);
		shader_set_uniform_f(rclight_uradiance_interval, global.rc_cascade_interval);
		shader_set_uniform_f(rclight_ucascade_scaling, global.rc_cascade_branch);
		shader_set_uniform_f(rclight_ucascade_index, i);
		
		shader_set_uniform_f(rclight_uresolution, global.rc_renderwidth, global.rc_renderheight);
		texture_set_stage(rclight_uworldscene, surface_get_texture(gameworld_worldscene));
		texture_set_stage(rclight_udistancefield, surface_get_texture(gameworld_distancefield));
		
		surface_set_target(gameworld_cascades[i]);
		draw_clear(c_black);
		draw_surface(gameworld_cascades[global.rc_cascade_count], 0, 0);
		surface_reset_target();
		shader_reset();
	}
	
	/*
	var rcmerge_ucascade_resolution = shader_get_uniform(Shd_RadianceMerging, "in_CascadeResolution");
	var rcmerge_uradiance_interval  = shader_get_uniform(Shd_RadianceMerging, "in_RadianceInterval");
	var rcmerge_ucascade_scaling    = shader_get_uniform(Shd_RadianceMerging, "in_CascadeScaling");
	var rcmerge_ucascade_index      = shader_get_uniform(Shd_RadianceMerging, "in_CascadeIndex");
	var rcmerge_uresolution         = shader_get_uniform(Shd_RadianceMerging, "in_Resolution");
	var rcmerge_ucascaden1          = shader_get_sampler_index(Shd_RadianceMerging, "in_CascadeN1");
	
	for(var i = global.rc_cascade_count - 2; i > -1; i--) {
		surface_set_target(gameworld_cascades[global.rc_cascade_count]);
		shader_set(Shd_RadianceMerging);
		shader_set_uniform_f(rcmerge_ucascade_resolution, global.rc_cascade_width, global.rc_cascade_height);
		shader_set_uniform_f(rcmerge_uradiance_interval, global.rc_cascade_interval);
		shader_set_uniform_f(rcmerge_ucascade_scaling, global.rc_cascade_branch);
		shader_set_uniform_f(rcmerge_ucascade_index, i);
		shader_set_uniform_f(rcmerge_uresolution, global.rc_renderwidth, global.rc_renderheight);
		texture_set_stage(rcmerge_ucascaden1, surface_get_texture(gameworld_cascades[i+1]));
		draw_surface(gameworld_cascades[i], 0, 0);
		shader_reset();
		surface_reset_target();
		
		surface_set_target(gameworld_cascades[i]);
		draw_surface(gameworld_cascades[global.rc_cascade_count], 0, 0);
		surface_reset_target();
	}
	*/

// Re-Enable Alpha Blending since the Global Illumination pass is complete.
gpu_set_blendenable(true);

draw_surface(gameworld_worldscene, 0, 0);
draw_surface(gameworld_jumpflood, 0, 0);
draw_surface(gameworld_distancefield, 0, 0);
//draw_surface(gameworld_radiance[0], 0, 0);
draw_surface(gameworld_cascades[global.showcascade], 0, 0);