/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = RANGED
	origin_tech = Tc_MATERIALS + "=3;" + Tc_COMBAT + "=3"
	var/projectile
	var/fire_sound


/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(var/obj/mecha/combat/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "General Energy Weapon"

/obj/item/mecha_parts/mecha_equipment/weapon/energy/become_defective()
	if(!defective)
		..()
		equip_cooldown = rand(equip_cooldown*1.5, equip_cooldown*2.5)
		energy_drain = rand(energy_drain*3, energy_drain*5)

/obj/item/mecha_parts/mecha_equipment/weapon/energy/action(atom/target)
	if(!action_checks(target))
		return
	var/originaltarget = target
	var/turf/curloc = chassis.loc
	var/atom/targloc = get_turf(target)
	if(defective)
		target = get_inaccuracy(originaltarget, 1, chassis)
		targloc = get_turf(target)
	if (!targloc || !istype(targloc, /turf) || !curloc)
		return
	if (targloc == curloc)
		return
	set_ready_state(0)
	playsound(chassis, fire_sound, 50, 1)
	var/obj/item/projectile/A = new projectile(curloc)
	A.firer = chassis.occupant
	A.original = target
	A.current = curloc
	A.starting = curloc
	A.yo = targloc.y - curloc.y
	A.xo = targloc.x - curloc.x
	chassis.use_power(energy_drain)
	A.OnFired()
	A.process()
	chassis.log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return


/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	equip_cooldown = 8
	name = "CH-PS \"Immolator\" Laser"
	icon_state = "mecha_laser"
	energy_drain = 30
	projectile = /obj/item/projectile/beam
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	equip_cooldown = 15
	name = "CH-LC \"Solaris\" Laser Cannon"
	icon_state = "mecha_laser"
	energy_drain = 60
	projectile = /obj/item/projectile/beam/heavylaser
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	equip_cooldown = 40
	name = "mkIV Ion Heavy Cannon"
	icon_state = "mecha_ion"
	energy_drain = 120
	projectile = /obj/item/projectile/ion
	fire_sound = 'sound/weapons/ion.ogg'


/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	equip_cooldown = 30
	name = "eZ-13 MK2 heavy pulse rifle"
	icon_state = "mecha_pulse"
	energy_drain = 120
	origin_tech = Tc_MATERIALS + "=3;" + Tc_COMBAT + "=6;" + Tc_POWERSTORAGE + "=4"
	projectile = /obj/item/projectile/beam/pulse/heavy
	fire_sound = 'sound/weapons/marauder.ogg'


/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "u_laser"
	damage = 60

/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	name = "\improper PBT \"Pacifier\" mounted taser"
	icon_state = "mecha_taser"
	energy_drain = 20
	equip_cooldown = 8
	projectile = /obj/item/projectile/energy/electrode
	fire_sound = 'sound/weapons/Taser.ogg'


/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "\improper HoNkER BlAsT 5000"
	icon_state = "mecha_honker"
	energy_drain = 200
	equip_cooldown = 150
	range = MELEE|RANGED

/obj/item/mecha_parts/mecha_equipment/weapon/honker/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/honker/action(target)
	if(!chassis)
		return 0
	if(energy_drain && chassis.get_charge() < energy_drain)
		return 0
	if(!equip_ready)
		return 0

	playsound(chassis, 'sound/items/AirHorn.ogg', 100, 1)
	chassis.occupant_message("<font color='red' size='5'>HONK</font>")
	for(var/mob/living/carbon/M in ohearers(6, chassis))
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.earprot())
				continue
		to_chat(M, "<font color='red' size='7'>HONK</font>")
		M.sleeping = 0
		M.stuttering += 20
		M.ear_deaf += 30
		M.Weaken(3)
		if(prob(30))
			M.Stun(10)
			M.Paralyse(4)
		else
			M.Jitter(500)
		/* //else the mousetraps are useless
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(isobj(H.shoes))
				var/thingy = H.shoes
				H.drop_from_inventory(H.shoes)
				walk_away(thingy,chassis,15,2)
				spawn(20)
					if(thingy)
						walk(thingy,0)
		*/
	chassis.use_power(energy_drain)
	log_message("Honked from [src.name]. HONK!")
	message_admins("[key_name_and_info(chassis.occupant)] used a Mecha Honker in ([formatJumpTo(chassis)])",0,1)
	log_game("[key_name(chassis.occupant)] used a Mecha Honker in ([formatJumpTo(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "General Ballisic Weapon"
	var/max_projectiles
	var/projectiles
	var/projectile_energy_cost

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/New()
	..()
	projectiles = max_projectiles

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/become_defective()
	if(!defective)
		..()
		equip_cooldown = rand(equip_cooldown*2, equip_cooldown*3)
		projectile_energy_cost = rand(projectile_energy_cost*1.5, projectile_energy_cost*3)
		max_projectiles = rand(max_projectiles/4, max_projectiles*0.75)
		if(max_projectiles < projectiles)
			projectiles = max_projectiles

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(atom/target)
	if(..())
		if(projectiles > 0)
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_equip_info()
	return "[..()]\[[src.projectiles]\][(src.projectiles < src.max_projectiles)?" - <a href='?src=\ref[src];rearm=1'>Rearm</a>":null]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/rearm()
	if(projectiles < max_projectiles)
		var/projectiles_to_add = max_projectiles - projectiles
		while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
			projectiles++
			projectiles_to_add--
			chassis.use_power(projectile_energy_cost)
	send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	log_message("Rearmed [src.name].")
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Topic(href, href_list)
	..()
	if (href_list["rearm"])
		src.rearm()
	return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "LBX AC 10 \"Scattershot\""
	icon_state = "mecha_scatter"
	equip_cooldown = 20
	projectile = /obj/item/projectile/bullet/midbullet
	fire_sound = 'sound/weapons/shotgun.ogg'
	max_projectiles = 40
	projectile_energy_cost = 25
	var/projectiles_per_shot = 4
//	var/deviation = 0.7  //the shots were perfectly accurate no matter what this was set to

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/action(atom/target)
	if(!action_checks(target))
		return
	var/originaltarget = target
	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if(!curloc || !targloc)
		return
//	var/target_x = targloc.x
//	var/target_y = targloc.y
//	var/target_z = targloc.z
//	targloc = null
	for(var/i=1 to min(projectiles, projectiles_per_shot))
//		targloc = locate(target_x+GaussRandRound(deviation,1),target_y+GaussRandRound(deviation,1),target_z)
		if(defective)
			target = get_inaccuracy(originaltarget, 2, chassis)
			targloc = get_turf(target)
		if(!targloc || targloc == curloc)
			break
		playsound(chassis, fire_sound, 80, 1)
		var/obj/item/projectile/A = getFromPool(projectile,curloc)//new projectile(curloc)
		src.projectiles--
		A.firer = chassis.occupant
		A.original = target
		A.current = curloc
		A.starting = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		set_ready_state(0)
		A.OnFired()
		A.process()
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return



/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "Ultra AC 2"
	icon_state = "mecha_uac2"
	equip_cooldown = 10
	projectile = /obj/item/projectile/bullet/weakbullet
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	max_projectiles = 300
	projectile_energy_cost = 20
	var/projectiles_per_shot = 3
//	var/deviation = 0.3

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/action(atom/target)
	if(!action_checks(target))
		return
	var/originaltarget = target
	var/turf/targloc = get_turf(target)
//	var/target_x = targloc.x
//	var/target_y = targloc.y
//	var/target_z = targloc.z
//	targloc = null
	spawn	for(var/i=1 to min(projectiles, projectiles_per_shot))
		if(!chassis)
			break
		var/turf/curloc = get_turf(chassis)
//		targloc = locate(target_x+GaussRandRound(deviation,1),target_y+GaussRandRound(deviation,1),target_z)
		if(defective)
			target = get_inaccuracy(originaltarget, 2, chassis)
			targloc = get_turf(target)
		if (!targloc || !curloc)
			continue
		if (targloc == curloc)
			continue

		playsound(chassis, fire_sound, 50, 1)
		var/obj/item/projectile/A = new projectile(curloc)
		src.projectiles--
		A.firer = chassis.occupant
		A.original = target
		A.current = curloc
		A.starting = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		A.OnFired()
		A.process()
		sleep(2)
	set_ready_state(0)
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	name = "SRM-8 Missile Rack"
	icon_state = "mecha_missilerack"
	projectile = /obj/item/missile
	fire_sound = 'sound/weapons/rocket.ogg'
	max_projectiles = 8
	projectile_energy_cost = 1000
	equip_cooldown = 60
	var/missile_speed = 2
	var/missile_range = 30

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/missile/M = new projectile(chassis.loc)
	M.primed = 1
	playsound(chassis, fire_sound, 50, 1)
	var/originaltarget = target
	if(defective)
		target = get_inaccuracy(originaltarget, 2, chassis)
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return


/obj/item/missile
	icon = 'icons/obj/grenade.dmi'
	icon_state = "missile"
	var/primed = null
	throwforce = 15

/obj/item/missile/throw_impact(atom/hit_atom)
	if(primed)
		explosion(hit_atom, 0, 1, 2)
		qdel(src)
	else
		..()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	name = "SGL-6 Grenade Launcher"
	icon_state = "mecha_grenadelnchr"
	projectile = /obj/item/weapon/grenade/flashbang
	fire_sound = 'sound/weapons/grenadelauncher.ogg'
	max_projectiles = 6
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 60
	var/det_time = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/weapon/grenade/flashbang/F = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	var/originaltarget = target
	if(defective)
		target = get_inaccuracy(originaltarget, 3, chassis)
	F.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	spawn(det_time)
		F.prime()
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang//Because I am a heartless bastard -Sieve
	name = "SOP-6 Grenade Launcher"
	projectile = /obj/item/weapon/grenade/flashbang/clusterbang

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/get_equip_info()//Limited version of the clusterbang launcher that can't reload
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[chassis.selected==src?"<b>":"<a href='?src=\ref[chassis];select_equip=\ref[src]'>"][src.name][chassis.selected==src?"</b>":"</a>"]\[[src.projectiles]\]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/rearm()
	return//Extra bit of security

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	name = "Banana Mortar"
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/weapon/bananapeel
	fire_sound = 'sound/items/bikehorn.ogg'
	max_projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/weapon/bananapeel/B = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 60, 1)
	B.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Bananed from [src.name], targeting [target]. HONK!")
	message_admins("[key_name_and_info(chassis.occupant)] banana'd \a [src] towards [target] ([formatJumpTo(chassis)])",0,1)
	log_game("[key_name(chassis.occupant)] banana'd \a [src] towards [target] ([formatLocation(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	name = "Mousetrap Mortar"
	icon_state = "mecha_mousetrapmrtr"
	projectile = /obj/item/device/assembly/mousetrap
	fire_sound = 'sound/items/bikehorn.ogg'
	max_projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 10

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/device/assembly/mousetrap/M = new projectile(chassis.loc)
	M.secured = 1
	playsound(chassis, fire_sound, 60, 1)
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Launched a mouse-trap from [src.name], targeting [target]. HONK!")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [target] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [target] ([formatLocation(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/creampie_mortar //why waste perfectly good food synthetizing technology in solving world hunger when you can have clowntide instead?
	name = "Rapid-Fire Cream Pie Mortar"
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/weapon/reagent_containers/food/snacks/pie/empty //because some chucklefuck will try to catch the pie somehow for free nutriment
	fire_sound = 'sound/items/bikehorn.ogg'
	max_projectiles = 15
	missile_speed = 0.75 //for maximum pie-traveling
	projectile_energy_cost = 100
	equip_cooldown = 5
	range = MELEE|RANGED

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/creampie_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/creampie_mortar/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/weapon/reagent_containers/food/snacks/pie/P = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 60, 1)
	P.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Cream-pied from [src.name], targeting [target]. HONK!")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [target] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [target] ([formatLocation(chassis)])")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas
	name = "PCMK-6 Bolas Launcher"
	icon_state = "mecha_bolas"
	projectile = /obj/item/weapon/legcuffs/bolas
	fire_sound = 'sound/weapons/whip.ogg'
	max_projectiles = 10
	missile_speed = 1
	missile_range = 30
	projectile_energy_cost = 50
	equip_cooldown = 10


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas/action(target)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/weapon/legcuffs/bolas/M = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	var/originaltarget = target
	if(defective)
		target = get_inaccuracy(originaltarget, 1, chassis)
	M.thrown_from = src
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [src.name], targeting [originaltarget].")
	message_admins("[key_name_and_info(chassis.occupant)] fired \a [src] towards [originaltarget] ([formatJumpTo(chassis)])",0,1)
	log_attack("[key_name(chassis.occupant)] fired \a [src] from [chassis] towards [originaltarget] ([formatLocation(chassis)])")
	do_after_cooldown()
	return