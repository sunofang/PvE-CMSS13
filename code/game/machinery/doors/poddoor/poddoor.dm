/obj/structure/machinery/door/poddoor
	name = "\improper Podlock"
	desc = "That looks like it doesn't open easily."
	icon = 'icons/obj/structures/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
	var/base_icon_state = "pdoor"
	id = 1
	dir = NORTH
	health = 0
	layer = PODDOOR_CLOSED_LAYER
	open_layer = PODDOOR_OPEN_LAYER
	closed_layer = PODDOOR_CLOSED_LAYER
	///How many tiles the shutter occupies
	var/shutter_length = 1

/obj/structure/machinery/door/poddoor/Initialize()
	. = ..()
	if(density)
		set_opacity(1)
	else
		set_opacity(0)
	update_icon()

/obj/structure/machinery/door/poddoor/update_icon()
	if(density)
		icon_state = "[base_icon_state]1"
	else
		icon_state = "[base_icon_state]0"

/obj/structure/machinery/door/poddoor/Collided(atom/movable/AM)
	if(!density)
		return ..()
	else
		return 0

/obj/structure/machinery/door/poddoor/attackby(obj/item/W, mob/user)
	add_fingerprint(user)
	if(!W.pry_capable)
		return
	if(density && (stat & NOPOWER) && !operating && !unacidable)
		spawn(0)
			operating = DOOR_OPERATING_OPENING
			flick("[base_icon_state]c0", src)
			icon_state = "[base_icon_state]0"
			set_opacity(0)
			sleep(15)
			density = FALSE
			operating = DOOR_OPERATING_IDLE

/obj/structure/machinery/door/poddoor/attack_alien(mob/living/carbon/xenomorph/X)
	if((stat & NOPOWER) && density && !operating && !unacidable)
		INVOKE_ASYNC(src, PROC_REF(pry_open), X)
		return XENO_ATTACK_ACTION

/obj/structure/machinery/door/poddoor/proc/pry_open(mob/living/carbon/xenomorph/X, time = 4 SECONDS)
	if(X.action_busy)
		return

	X.visible_message(SPAN_DANGER("[X] begins prying [src] open."),\
	SPAN_XENONOTICE("You start prying [src] open."), max_distance = 3)

	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, TRUE)

	if(!do_after(X, time, INTERRUPT_ALL, BUSY_ICON_HOSTILE, src, INTERRUPT_ALL))
		to_chat(X, "You stop prying [src] open.")
		return

	X.visible_message(SPAN_DANGER("[X] pries open [src]."), \
	SPAN_XENONOTICE("You pry open [src]."), max_distance = 3)

	open()
	return TRUE


/obj/structure/machinery/door/poddoor/try_to_activate_door(mob/user)
	return

/obj/structure/machinery/door/poddoor/open(forced = FALSE)
	if(operating) //doors can still open when emag-disabled
		return FALSE
	if(!opacity)
		return TRUE

	operating = DOOR_OPERATING_OPENING

	playsound(loc, 'sound/machines/blastdoor.ogg', 20, 0)
	flick("[base_icon_state]c0", src)
	icon_state = "[base_icon_state]0"
	set_opacity(0)

	addtimer(CALLBACK(src, PROC_REF(finish_open)), openspeed, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT)
	return TRUE

/obj/structure/machinery/door/poddoor/close(forced = FALSE)
	if(operating)
		return FALSE
	if(opacity == initial(opacity))
		return TRUE

	operating = DOOR_OPERATING_CLOSING
	playsound(loc, 'sound/machines/blastdoor.ogg', 20, 0)

	layer = closed_layer
	flick("[base_icon_state]c1", src)
	icon_state = "[base_icon_state]1"
	density = TRUE
	set_opacity(initial(opacity))

	addtimer(CALLBACK(src, PROC_REF(finish_close)), openspeed, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT)
	return TRUE

/obj/structure/machinery/door/poddoor/finish_close()
	if(operating != DOOR_OPERATING_CLOSING)
		return

	operating = DOOR_OPERATING_IDLE

/obj/structure/machinery/door/poddoor/filler_object
	name = ""
	icon = null
	icon_state = ""
	unacidable = TRUE
