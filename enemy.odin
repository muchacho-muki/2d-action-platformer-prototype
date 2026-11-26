package main

import rl "vendor:raylib"
import b2 "vendor:box2d"
import rand "core:math/rand"
import "core:fmt"

//loads enemy textures and appends them
Enemy_tex :: proc() -> [dynamic]rl.Texture2D{
	enemyTextures : [dynamic]rl.Texture2D
	append(&enemyTextures, rl.LoadTexture("assets/enemy/idle.png"))
	return enemyTextures
}

//just draws enemy (positioning logic needs to be better so we are not multiplying and dividing by magic numbers)
Draw_Enemy :: proc(enemy : Entity){
    tex := enemy.texture[enemy.State]
    pos := b2.Body_GetPosition(enemy.Physics_body)

    w := f32(tex.width)
    h := f32(tex.height)

    source := rl.Rectangle{0, 0, w * f32(enemy.facing), h}

    dest   := rl.Rectangle{pos.x - (w * 1.5 )/ 2, pos.y - (h * 1.5) / 2, w * 1.5, h * 1.5}
    rl.DrawTexturePro(tex, source, dest, {0, 0}, 0, rl.WHITE)
}

//updates the direction so it always follows/chases the player
Enemy_Chase :: proc(enemy : ^Entity, player: Entity){
	enemy_pos:= b2.Body_GetPosition(enemy.Physics_body)
	player_pos:= b2.Body_GetPosition(player.Physics_body)

	enemy.wants_jump = true

	enemy.move_dir = .none

	if player_pos.x < enemy_pos.x {enemy.move_dir = .left; enemy.facing = .left;}
	else if player_pos.x > enemy_pos.x{enemy.move_dir = .right; enemy.facing = .right;}

	Movement(enemy)
}

//area where enemy can attack and get hit
Enemy_boxes :: proc(enemy : Entity) -> rl.Rectangle{
		enemy_pos:= b2.Body_GetPosition(enemy.Physics_body)

		pos_x := enemy_pos.x - enemy.size.x / 2
		pos_y := enemy_pos.y - enemy.size.y / 2

		return rl.Rectangle{pos_x , pos_y, enemy.size.x, enemy.size.y}
}

//attacks the player (have disabled attack cuz it was annoying while debugging but it is fully functional)
Enemy_attack :: proc(enemy : Entity, player: ^Entity){
	if enemy.wants_attack &&  rl.CheckCollisionRecs(Player_hurtbox(player^), Enemy_boxes(enemy)){
		// player.Health -= 4.0
		// Knockback(player, f32(enemy.facing), 0.5, 1.0)

		if player.Health <= 0{
			fmt.print("gameover")
			}
	}
}

//creates the given amount of enemy with adjustable difficulty
Create_enemies :: proc(Enemies_list : ^[dynamic]Entity, amount: int, diff: f32){
	tex:= Enemy_tex()
	for i in 0..<amount{
		enemy := Entity{
		texture = tex,
		State = .idle,
		category = ENEMY_Collision,
		mask = GROUND_Collision,

		wants_attack = true,

		pos = {rand.float32_range(0.0, 1500.0), 400},
		size = {20, 20},
		speed = rand.float32_range(100.0, 300.0) * diff,
		jump_boost = rand.float32_range(100.0, 300.0) * diff,
		Health = 10.0 * diff,
		damage = 10.0 * diff,
		}
		Create_Entity_Physics_body(&enemy)

		append(Enemies_list, enemy)
	}
}

//contains all the nessessary proc to update and draw the enemy
Update_enemies :: proc(Enemies_list : ^[dynamic]Entity, player: ^Entity){
	for &enemy in Enemies_list{
		Enemy_Chase(&enemy, player^)
		Enemy_attack(enemy, player)
		Draw_Enemy(enemy)
	}
}