/datum/computer_file/program/arcade
	filename = "dsarcade"
	filedesc = "Микроаркада Донксофт"
	program_icon_state = "arcade"
	extended_desc = "Это ремастер классической адвенчуры 'Кубинец Пит'. Она была адаптированна для пда и планшетов, а так же получила выдающуюся графику и леденящий душу сюжет."
	requires_ntnet = FALSE
	size = 6
	tgui_id = "NtosArcade"
	program_icon = "gamepad"

	///Returns TRUE if the game is being played.
	var/game_active = TRUE
	///This disables buttom actions from having any impact if TRUE. Resets to FALSE when the player is allowed to make an action again.
	var/pause_state = FALSE
	var/boss_hp = 45
	var/boss_mp = 15
	var/player_hp = 30
	var/player_mp = 10
	var/ticket_count = 0
	///Shows what text is shown on the app, usually showing the log of combat actions taken by the player.
	var/heads_up = "Победители приносят деньги Нанотрезен."
	var/boss_name = "Миньон Кубинца Пита"
	///Determines which boss image to use on the UI.
	var/boss_id = 1

/datum/computer_file/program/arcade/proc/game_check(mob/user)
	sleep(0.5 SECONDS)
	user?.mind?.adjust_experience(/datum/skill/gaming, 1)
	if(boss_hp <= 0)
		heads_up = "Ты победил [boss_name]! Поздравляем!"
		playsound(computer.loc, 'sound/arcade/win.ogg', 50)
		game_active = FALSE
		program_icon_state = "arcade_off"
		if(istype(computer))
			computer.update_appearance()
		ticket_count += 1
		user?.mind?.adjust_experience(/datum/skill/gaming, 50)
		usr.won_game()
		sleep(1 SECONDS)
	else if(player_hp <= 0 || player_mp <= 0)
		heads_up = "Поражение... Станция обречена?"
		playsound(computer.loc, 'sound/arcade/lose.ogg', 50)
		game_active = FALSE
		program_icon_state = "arcade_off"
		if(istype(computer))
			computer.update_appearance()
		user?.mind?.adjust_experience(/datum/skill/gaming, 10)
		usr.lost_game()
		sleep(1 SECONDS)

/datum/computer_file/program/arcade/proc/enemy_check(mob/user)
	var/boss_attackamt = 0 //Spam protection from boss attacks as well.
	var/boss_mpamt = 0
	var/bossheal = 0
	if(pause_state == TRUE)
		boss_attackamt = rand(3,6)
		boss_mpamt = rand (2,4)
		bossheal = rand (4,6)
	if(game_active == FALSE)
		return
	if (boss_mp <= 5)
		heads_up = "[boss_mpamt] похитил у тебя ману!"
		playsound(computer.loc, 'sound/arcade/steal.ogg', 50, TRUE)
		player_mp -= boss_mpamt
		boss_mp += boss_mpamt
	else if(boss_mp > 5 && boss_hp <12)
		heads_up = "[boss_name] восстанавливает себе [bossheal] здоровья!"
		playsound(computer.loc, 'sound/arcade/heal.ogg', 50, TRUE)
		boss_hp += bossheal
		boss_mp -= boss_mpamt
	else
		heads_up = "[boss_name] атакует тебя, нанося [boss_attackamt] урона!"
		playsound(computer.loc, 'sound/arcade/hit.ogg', 50, TRUE)
		player_hp -= boss_attackamt

	pause_state = FALSE
	game_check()

/datum/computer_file/program/arcade/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/arcade),
	)

/datum/computer_file/program/arcade/ui_data(mob/user)
	var/list/data = get_header_data()
	data["Hitpoints"] = boss_hp
	data["PlayerHitpoints"] = player_hp
	data["PlayerMP"] = player_mp
	data["TicketCount"] = ticket_count
	data["GameActive"] = game_active
	data["PauseState"] = pause_state
	data["Status"] = heads_up
	data["BossID"] = "boss[boss_id].gif"
	return data

/datum/computer_file/program/arcade/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	usr.played_game()

	var/gamerSkillLevel = 0
	var/gamerSkill = 0
	if(usr?.mind)
		gamerSkillLevel = usr.mind.get_skill_level(/datum/skill/gaming)
		gamerSkill = usr.mind.get_skill_modifier(/datum/skill/gaming, SKILL_RANDS_MODIFIER)
	switch(action)
		if("Attack")
			var/attackamt = 0 //Spam prevention.
			if(pause_state == FALSE)
				attackamt = rand(2,6) + rand(0, gamerSkill)
			pause_state = TRUE
			heads_up = "Атакую, нанося [attackamt] урона."
			playsound(computer.loc, 'sound/arcade/hit.ogg', 50, TRUE)
			boss_hp -= attackamt
			sleep(1 SECONDS)
			game_check()
			enemy_check()
			return TRUE
		if("Heal")
			var/healamt = 0 //More Spam Prevention.
			var/healcost = 0
			if(pause_state == FALSE)
				healamt = rand(6,8) + rand(0, gamerSkill)
				var/maxPointCost = 3
				if(gamerSkillLevel >= SKILL_LEVEL_JOURNEYMAN)
					maxPointCost = 2
				healcost = rand(1, maxPointCost)
			pause_state = TRUE
			heads_up = "Лечусь, восстанавливая [healamt] здоровья."
			playsound(computer.loc, 'sound/arcade/heal.ogg', 50, TRUE)
			player_hp += healamt
			player_mp -= healcost
			sleep(1 SECONDS)
			game_check()
			enemy_check()
			return TRUE
		if("Recharge_Power")
			var/rechargeamt = 0 //As above.
			if(pause_state == FALSE)
				rechargeamt = rand(4,7) + rand(0, gamerSkill)
			pause_state = TRUE
			heads_up = "Перевожу дух, восстанавливая [rechargeamt] маны."
			playsound(computer.loc, 'sound/arcade/mana.ogg', 50, TRUE)
			player_mp += rechargeamt
			sleep(1 SECONDS)
			game_check()
			enemy_check()
			return TRUE
		if("Dispense_Tickets")
			if(computer.stored_paper <= 0)
				to_chat(usr, span_notice("Аппаратная ошибка: в принтере закончилась бумага."))
				return
			else
				computer.visible_message(span_notice("[computer] печатает бумагу."))
				if(ticket_count >= 1)
					new /obj/item/stack/arcadeticket((get_turf(computer)), 1)
					to_chat(usr, span_notice("[computer] выдаёт билет!"))
					ticket_count -= 1
					computer.stored_paper -= 1
				else
					to_chat(usr, span_notice("У вас нет билетов!"))
				return TRUE
		if("Start_Game")
			game_active = TRUE
			boss_hp = 45
			player_hp = 30
			player_mp = 10
			heads_up = "Ты предстал перед [boss_name]! Приготовься к битве!"
			program_icon_state = "arcade"
			boss_id = rand(1,6)
			pause_state = FALSE
			if(istype(computer))
				computer.update_appearance()
