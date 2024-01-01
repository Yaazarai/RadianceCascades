/*
	Radiance Cascades solves the rendering equation by having several
	grids of radiance probes (cascades) within a scene that check raymarch
	for light at varying intervals (distances and ranges) away from the
	radiance probes depending on the N-index of the cascade.
	
	Lower cascades have higher linear resolution and sample closer to the
	the probes with less rays-per-probe and have more probes per cascade.
	
	Higher cascades have higher anuglar resolution and sample further from
	the probes with more rays-per-probe and have less probes per cascade.
	
	This is due to how penumbras (edges of shadows) work where the accuracy
	of the shadow (how blurry it is) is sharper closer to light sources and
	blurrier further from light sources. Neat!
*/
// Disable Surface Depth Buffer (for memory profiling).
surface_depth_disable(true);

global.rc_uselightbounce   = false;
global.rc_frameswap        = false;  // swaps render-frames for raybounces.
global.rc_renderwidth      = 1024.0; // render width resolution.
global.rc_renderheight     = 1024.0; // render height resolution.
global.rc_renderdiagonal   = point_distance(0.0, 0.0, global.rc_renderwidth, global.rc_renderheight);
global.rc_cascade_angular  = 4.0; // angular resolution or initial rays per probe in cascade[0].
global.rc_cascade_scaling  = 4.0; // multiplier for probes / intervals.
global.rc_cascade_interval = 4.0; // radiance interval or distance between radiance probes.
global.rc_cascade_overlap  = 1.5; // radiance interval overlap between probes.
global.rc_cascade_width    = floor(global.rc_renderwidth / global.rc_cascade_interval) * global.rc_cascade_angular;
global.rc_cascade_height   = floor(global.rc_renderheight / global.rc_cascade_interval) * global.rc_cascade_angular;
global.rc_cascade_count    = floor(logn(global.rc_cascade_scaling, global.rc_renderdiagonal) - logn(global.rc_cascade_scaling, global.rc_cascade_interval)) + 1;

var bytes = 4.0 * global.rc_cascade_width * global.rc_cascade_height * global.rc_cascade_count;
show_debug_message("\nCascade Width:  {0}", string(global.rc_cascade_width));
show_debug_message(  "Cascade Height: {0}", string(global.rc_cascade_height));
show_debug_message(  "Cascade Count:  {0}", string(global.rc_cascade_count));
show_debug_message(  "Cascade Anglr:  {0}", string(global.rc_cascade_angular));
show_debug_message(  "Cascade Intrv:  {0}", string(global.rc_cascade_interval));
show_debug_message(  "Cascade Memory: {0} MB\n", string(bytes / 1024 / 1024));

global.showcascade = 0;
rclight_defaultshaders(global.rc_renderwidth, global.rc_renderheight);

#macro INVALID_SURFACE -1
gameworld_worldscene = INVALID_SURFACE;
gameworld_temporary = INVALID_SURFACE;
gameworld_jumpflood = INVALID_SURFACE;
gameworld_distancefield = INVALID_SURFACE;

for(var i = 0; i < global.rc_cascade_count + 1; i++)
	gameworld_cascades[i] = INVALID_SURFACE;

gameworld_radiance[0] = INVALID_SURFACE; // current or previous frame.
gameworld_radiance[1] = INVALID_SURFACE; // current or previous frame.