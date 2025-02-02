/datum/plane_holder/New(mob/this_guy)
	..()
	plane_masters[VIS_CH_STATUS_R] 		= new /atom/movable/screen/plane_master{plane = PLANE_CH_STATUS_R}			//Right-side status icon
	plane_masters[VIS_CH_HEALTH_VR] 	= new /atom/movable/screen/plane_master{plane = PLANE_CH_HEALTH_VR}			//Health bar but transparent at 100
	plane_masters[VIS_CH_BACKUP] 		= new /atom/movable/screen/plane_master{plane = PLANE_CH_BACKUP}				//Backup implant status
	plane_masters[VIS_CH_VANTAG] 		= new /atom/movable/screen/plane_master{plane = PLANE_CH_VANTAG}				//Vore Antags

	plane_masters[VIS_AUGMENTED]		= new /atom/movable/screen/plane_master/augmented(null, my_mob)					//Augmented reality

/////////////////
//AR planemaster does some special image handling
/atom/movable/screen/plane_master/augmented
	plane = PLANE_AUGMENTED
	var/state = FALSE //Saves cost with the lists
	var/mob/my_mob

/atom/movable/screen/plane_master/augmented/Initialize(mapload, mob/new_mob)
	. = ..()
	my_mob = new_mob

/atom/movable/screen/plane_master/augmented/Destroy()
	my_mob = null
	return ..()

/atom/movable/screen/plane_master/augmented/set_visibility(var/want = FALSE)
	. = ..()
	state = want
	apply()

/atom/movable/screen/plane_master/augmented/proc/apply()
	if(!my_mob.client)
		return

	if(state)
		entopic_users |= my_mob
		if(my_mob.client)
			my_mob.client.images |= entopic_images
	else
		entopic_users -= my_mob
		if(my_mob.client)
			my_mob.client.images -= entopic_images
