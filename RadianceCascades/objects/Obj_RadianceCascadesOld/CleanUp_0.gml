if (surface_exists(gameworld_worldscene)) surface_free(gameworld_worldscene);
if (surface_exists(gameworld_temporary)) surface_free(gameworld_temporary);
if (surface_exists(gameworld_jumpflood)) surface_free(gameworld_jumpflood);
if (surface_exists(gameworld_distancefield)) surface_free(gameworld_distancefield);

for(var i = 0; i < global.rc_cascade_count + 1; i++)
	if (surface_exists(gameworld_cascades[i])) surface_free(gameworld_cascades[i]);

if (surface_exists(gameworld_radiance[0])) surface_free(gameworld_radiance[0]);
if (surface_exists(gameworld_radiance[1])) surface_free(gameworld_radiance[1]);