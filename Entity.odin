package main

import rl "vendor:raylib"
import b2 "vendor:box2d"

//making directions more readable
Direction :: enum i8{
	left = -1,
	none = 0,
	right = 1
}

//Entity states
State :: enum i8{
	idle = 0,
	attack = 1,
}

//bigass entity struct
Entity :: struct{
	texture: [dynamic]rl.Texture2D,
	animation: Animations,

	category: u64,
	mask: u64,

	Physics_body: b2.BodyId,

	pos: [2]f32,
	size: [2]f32,

	move_dir: Direction,
	facing:Direction, 
	State: State,

	Health: f32,
	damage: f32,
	speed: f32,
	jump_boost: f32,
	
	attack_timer: f32,
	stunt_timer: f32,

	wants_jump: bool,
	is_on_floor: bool,
	wants_attack: bool,
}

// creates the physics body for the entity, i think its called a bodyid in box2d
Create_Entity_Physics_body :: proc(E : ^Entity){
	bodyDef := b2.DefaultBodyDef()
	bodyDef.type = .dynamicBody
	bodyDef.position = E.pos
	bodyDef.motionLocks = {angularZ = true}
	E.Physics_body = b2.CreateBody(WorldId, bodyDef)

	dynamicBox := b2.MakeBox(E.size.x / 2, E.size.y / 2)
	shapeDef := b2.DefaultShapeDef()
	shapeDef.density = 0.1
	shapeDef.material.friction = 0.0

	// for hit box and stuff

	shapeDef.enableSensorEvents = true
	shapeDef.userData = E // NEW: so a hit can tell us who owns this body
	shapeDef.filter.categoryBits = E.category
	shapeDef.filter.maskBits = E.mask

	_ = b2.CreatePolygonShape(E.Physics_body, shapeDef, dynamicBox);
}

//handles movements based on the given directions, oh and also handles jumps
Movement :: proc(E : ^Entity){
	if E.stunt_timer > 0 { E.stunt_timer -= dt; return}

	vel := b2.Body_GetLinearVelocity(E.Physics_body)
	E.is_on_floor = Is_Grounded(E)

	if E.wants_jump && E.is_on_floor{
		vel.y = -E.jump_boost
	}

	vel.x = f32(E.move_dir) * E.speed
	b2.Body_SetLinearVelocity(E.Physics_body, vel)
}

//checks if we are on ground on nah, i am still a bit confused on how it works
Is_Grounded :: proc(E: ^Entity) -> bool {
	pos := b2.Body_GetPosition(E.Physics_body)

	// start slightly inside the feet, so the ray won't hit the player itself
	origin := b2.Vec2{pos.x, pos.y + E.size.y / 2 - 2}
	// cast 5 pixels downward (y points down in your game)
	translation := b2.Vec2{0, 5}

	result := b2.World_CastRayClosest(WorldId, origin, translation, b2.DefaultQueryFilter())
	return result.hit
}

//takes the facing direction of the attacker and launches the victim on that direction
Knockback :: proc(E: ^Entity, hit_dir: f32, time:f32, multiplier: f32){
	vel := b2.Body_GetLinearVelocity(E.Physics_body)
	E.move_dir = .none
	vel.y = -300 * multiplier
	vel.x = 500 *multiplier * hit_dir
	b2.Body_SetLinearVelocity(E.Physics_body, vel)
	E.stunt_timer = time
}

//draws all the hit and hurt boxes
Draw_boxes :: proc(player : Entity, enemy_list : [dynamic]Entity, display: bool){
	if !(display){return}
	rl.DrawRectangleLinesEx(Player_hitbox(player), 2.0, rl.RED)
	rl.DrawRectangleLinesEx(Player_hurtbox(player), 2.0, rl.GREEN)

	for enemy in enemy_list{
		rl.DrawRectangleLinesEx(Enemy_boxes(enemy), 2.0, rl.BLUE)
	}
}