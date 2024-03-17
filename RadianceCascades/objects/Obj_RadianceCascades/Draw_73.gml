// Disable blending for Jump Flood render processes (we don't care about alpha components here).
gpu_set_blendenable(false);

	// Generate the JFA + SDF of the world scene.
	radiance_jfaseed(gameworld_worldscene, gameworld_temporary, gameworld_jumpflood);
	radiance_jumpflood(gameworld_temporary, gameworld_jumpflood);
	radiance_distancefield(gameworld_jumpflood, gameworld_distancefield);
	radiance_clear(gameworld_storage);

// Calculate initial Radiance Intervals.
radiancecascades_intervals(gameworld_worldscene, gameworld_distancefield, gameworld_cascades, gameworld_storage);

// Merged Radiance Intervals from Cascades.
//radiancecascades_merging(gameworld_cascades, gameworld_storage);

// Merge Cascade 0 into itself with interpolation.
radiancecascades_mipmap(gameworld_cascades, gameworld_mipmaps);

// Re-Enable Alpha Blending since the Jump Flood pass is complete.
gpu_set_blendenable(true);

//draw_surface(gameworld_worldscene, 0, 0);
//draw_surface(gameworld_jumpflood, 0, 0);
//draw_surface(gameworld_distancefield, 0, 0);

var xscale = global.radiance_render_extent / global.radiance_cascade_extent;
var yscale = global.radiance_render_extent / global.radiance_cascade_extent;
//draw_surface_ext(gameworld_cascades[global.showcascade], 0, 0, xscale, yscale, 0, c_white, 1);

xscale = global.radiance_render_extent / surface_get_width(gameworld_mipmaps[global.showcascade]);
yscale = global.radiance_render_extent / surface_get_height(gameworld_mipmaps[global.showcascade]);
draw_surface_ext(gameworld_mipmaps[global.showcascade], 0, 0, xscale, yscale, 0, c_white, 1);

//draw_surface_ext(gameworld_cascades[global.showcascade], 0, 0, xscale, yscale, 0, c_white, 1);
draw_sprite_ext(Spr_SampleSceneBright, 0, 0, 0, 1, 1, 0, c_white, 1);