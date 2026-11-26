package main

import rl "vendor:raylib"
import b2 "vendor:box2d"
import "core:fmt"

//loads and append textures for the player
Player_tex :: proc() -> [dynamic]rl.Texture2D{
	playerTextures : [dynamic]rl.Texture2D
	append(&playerTextures, rl.LoadTexture("assets/player/idle_sheet.png"))
	append(&playerTextures, rl.LoadTexture("assets/player/attack_sheet.png"))
	return playerTextures
}

//draws the textures (need some rework)
Draw_Player :: proc(player: ^Entity) {
    tex := player.texture[player.State]
    pos := b2.Body_GetPosition(player.Physics_body)

    offset_x : f32 = -25
    if player.facing == .left{offset_x = -75} 
    offset_y : f32 = f32(-tex.height)

    pos = {pos.x + offset_x, pos.y + offset_y}

    Animate(&player.animation, pos, f32(player.facing), tex)
}

//temprory i will fix it with something better
Update_Player_Animation :: proc(player: ^Entity) {
    if player.wants_attack && player.attack_timer <= 0 {
        player.State = .attack
        player.animation.frames_speed = 10
        player.attack_timer = 0.3
    }

    if player.attack_timer > 0 {
        player.attack_timer -= dt
        if player.attack_timer <= 0 {
        	player.animation.frames_speed = 5
            player.State = .idle
        }
    }
}

//takes player input
Player_Input :: proc(player: ^Entity){
	player.move_dir = .none

	if rl.IsKeyDown(.D) { player.move_dir = .right; player.facing = .right;}
	if rl.IsKeyDown(.A) { player.move_dir = .left; player.facing = .left;}
	player.wants_jump = rl.IsKeyDown(.SPACE)
	player.wants_attack = rl.IsKeyPressed(.K)

	Movement(player)
}

//as the name suggests, if player wants to attack, it attacks
Player_attack :: proc(player: ^Entity, enemies: ^[dynamic]Entity){
	for &enemy, id in enemies{
		if player.wants_attack &&  rl.CheckCollisionRecs(Enemy_boxes(enemy), Player_hitbox(player^)){
		enemy.Health -= 4.0
		Knockback(&enemy, f32(player.facing), 1.0, 1.0)

		if enemy.Health <= 0{
			b2.DestroyBody(enemy.Physics_body)
			unordered_remove(enemies, id)
			}
		}
	}
}

//area of what player can hit
Player_hitbox :: proc(player : Entity) -> rl.Rectangle{
		player_pos:= b2.Body_GetPosition(player.Physics_body)

		offset_x := player.size.x

		pos_x := player_pos.x - player.size.x + offset_x * f32(player.facing)
		pos_y := player_pos.y - player.size.y / 2

		return rl.Rectangle{pos_x , pos_y, player.size.x * 2, player.size.y + 10}
}

//area of where player can get hurt
Player_hurtbox :: proc(player : Entity) -> rl.Rectangle{
		player_pos:= b2.Body_GetPosition(player.Physics_body)

		pos_x := player_pos.x - player.size.x / 2
		pos_y := player_pos.y - player.size.y / 2

		return rl.Rectangle{pos_x , pos_y, player.size.x, player.size.y}
}

//puts all the proc in order for the main game loop
Update_player :: proc(player: ^Entity, enemy_list : ^[dynamic]Entity){
	Player_Input(player)
	Player_attack(player, enemy_list)
	Update_Player_Animation(player)
	Draw_Player(player)
}