package main

import rl "vendor:raylib"
import b2 "vendor:box2d"

//keeps animation related data
Animations :: struct{
	frames_speed: int,
	scale: f32,
	frame_size: [2]i32,
	frames_timer: f32,
	current_frame : int,
}

//animates
Animate :: proc(ani: ^Animations, pos: [2]f32, facing: f32, tex: rl.Texture2D) {
	frame_amount:= tex.width / ani.frame_size.x 

    frame_time := 1.0 / f32(ani.frames_speed)   // seconds each frame is shown
	ani.frames_timer += dt

    if ani.frames_timer >= frame_time {
        ani.frames_timer -= frame_time
        ani.current_frame += 1

        if ani.current_frame >= int(frame_amount) {
            ani.current_frame = 0
        }
    }

    frame_w := f32(tex.width) / f32(frame_amount)
    frame_rec := rl.Rectangle{f32(ani.current_frame) * frame_w, 0, frame_w * facing, f32(tex.height)}

    dest := rl.Rectangle{pos.x, pos.y, frame_w * ani.scale, f32(tex.height) * ani.scale}
	rl.DrawTexturePro(tex, frame_rec, dest, {0,0}, 0, rl.WHITE)
}

//makes a 2d camera
make_cam :: proc() -> rl.Camera2D{
	cam := rl.Camera2D{
    		offset = {f32(rl.GetScreenWidth()) / 2, f32(rl.GetScreenHeight()) / 2},
    		target = {0, 0},
    		rotation = 0,
    		zoom = 2.0,
		}
	return cam
}

//updates camera x pos, y is const
update_cam :: proc(cam : ^rl.Camera2D, player : Entity){
	pos:= b2.Body_GetPosition(player.Physics_body)
	cam.target = {pos.x , 650}
}