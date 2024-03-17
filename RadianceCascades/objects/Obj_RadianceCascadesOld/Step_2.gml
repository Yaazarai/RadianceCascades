global.showcascade += keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
global.showcascade = clamp(global.showcascade, 0, global.rc_cascade_count - 1);

global.rc_frameswap = !global.rc_frameswap;
global.rc_cascade_width  = floor(global.rc_renderwidth / global.rc_cascade_interval) * global.rc_cascade_angular;
global.rc_cascade_height = floor(global.rc_renderheight / global.rc_cascade_interval) * global.rc_cascade_angular;
global.rc_cascade_count  = floor(logn(global.rc_cascade_branch, global.rc_renderdiagonal) - logn(global.rc_cascade_branch, global.rc_cascade_interval)) + 1;