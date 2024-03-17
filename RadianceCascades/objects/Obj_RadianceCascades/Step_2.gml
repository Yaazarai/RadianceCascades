global.showcascade += keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
global.showcascade = clamp(global.showcascade, 0, global.radiance_cascade_count - 1);