if (!surface_exists(gameworld_worldscene)) gameworld_worldscene = surface_create(global.rc_renderwidth, global.rc_renderheight);
if (!surface_exists(gameworld_temporary)) gameworld_temporary = surface_create(global.rc_renderwidth, global.rc_renderheight);
if (!surface_exists(gameworld_jumpflood)) gameworld_jumpflood = surface_create(global.rc_renderwidth, global.rc_renderheight);
if (!surface_exists(gameworld_distancefield)) gameworld_distancefield = surface_create(global.rc_renderwidth, global.rc_renderheight);

for(var i = 0; i < global.rc_cascade_count + 1; i++)
	if (!surface_exists(gameworld_cascades[i]))
		gameworld_cascades[i] = surface_create(global.rc_cascade_width, global.rc_cascade_height);

if (!surface_exists(gameworld_radiance[0])) gameworld_radiance[0] = surface_create(global.rc_renderwidth, global.rc_renderheight);
if (!surface_exists(gameworld_radiance[1])) gameworld_radiance[1] = surface_create(global.rc_renderwidth, global.rc_renderheight);