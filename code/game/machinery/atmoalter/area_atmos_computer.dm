/obj/machinery/computer/area_atmos
	name = "Area Air Control"
	desc = "A computer used to control the stationary scrubbers and pumps in the area."
	icon_keyboard = "atmos_key"
	icon_screen = "area_atmos"
	light_color = "#e6ffff"
	circuit = /obj/item/circuitboard/area_atmos

	var/list/connectedscrubbers = list()
	var/status = ""

	var/range = 25

	//Simple variable to prevent me from doing attack_hand in both this and the child computer
	var/zone = "This computer is working on a wireless range, the range is currently limited to "

/obj/machinery/computer/area_atmos/Initialize(mapload)
	. = ..()
	scanscrubbers()

/obj/machinery/computer/area_atmos/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/area_atmos/attack_hand(var/mob/user as mob)
	if(..(user))
		return
	var/dat = {"
	<html>
		<head>
			<style type="text/css">
				a.green:link
				{
					color:#00CC00;
				}
				a.green:visited
				{
					color:#00CC00;
				}
				a.green:hover
				{
					color:#00CC00;
				}
				a.green:active
				{
					color:#00CC00;
				}
				a.red:link
				{
					color:#FF0000;
				}
				a.red:visited
				{
					color:#FF0000;
				}
				a.red:hover
				{
					color:#FF0000;
				}
				a.red:active
				{
					color:#FF0000;
				}
			</style>
		</head>
		<body>
			<center><h1>Area Air Control</h1></center>
			<font color="red">[status]</font><br>
			<a href="?src=\ref[src];scan=1">Scan</a>
			<table border="1" width="90%">"}
	for(var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber in connectedscrubbers)
		dat += {"
				<tr>
					<td>
						[scrubber.name]<br>
						Pressure: [round(scrubber.air_contents.return_pressure(), 0.01)] kPa<br>
						Flow Rate: [round(scrubber.last_flow_rate,0.1)] L/s<br>
					</td>
					<td width="150">
						<a class="green" href="?src=\ref[src];scrub=\ref[scrubber];toggle=1">Turn On</a>
						<a class="red" href="?src=\ref[src];scrub=\ref[scrubber];toggle=0">Turn Off</a><br>
						Load: [round(scrubber.last_power_draw)] W
					</td>
				</tr>"}

	dat += {"
			</table><br>
			<i>[zone]</i>
		</body>
	</html>"}
	user << browse("[dat]", "window=miningshuttle;size=400x400")
	status = ""

/obj/machinery/computer/area_atmos/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)


	if(href_list["scan"])
		scanscrubbers()
	else if(href_list["toggle"])
		var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber = locate(href_list["scrub"])

		if(!validscrubber(scrubber))
			spawn(20)
				status = "ERROR: Couldn't connect to scrubber! (timeout)"
				connectedscrubbers -= scrubber
				src.updateUsrDialog()
			return

		scrubber.on = text2num(href_list["toggle"])
		scrubber.update_icon()

/obj/machinery/computer/area_atmos/proc/validscrubber(obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber as obj)
	if(!isobj(scrubber) || get_dist(scrubber.loc, src.loc) > src.range || scrubber.loc.z != src.loc.z)
		return FALSE
	return TRUE

/obj/machinery/computer/area_atmos/proc/scanscrubbers()
	connectedscrubbers.Cut()

	var/found = 0
	for(var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber in range(range, src.loc))
		found = 1
		connectedscrubbers += scrubber

	if(!found)
		status = "ERROR: No scrubber found!"

	updateUsrDialog()

// The one that only works in the same map area
/obj/machinery/computer/area_atmos/area
	zone = "This computer is working in a wired network limited to this area."

/obj/machinery/computer/area_atmos/area/scanscrubbers()
	connectedscrubbers.Cut()

	var/found = 0
	var/area/A = get_area(src)
	for(var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber in A)
		connectedscrubbers += scrubber
		found = 1

	if(!found)
		status = "ERROR: No scrubber found!"

	src.updateUsrDialog()

/obj/machinery/computer/area_atmos/area/validscrubber(var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber)
	if(get_area(scrubber) == get_area(src))
		return 1

	return 0

// The one that only works in the same map area
/obj/machinery/portable_atmospherics/powered/scrubber/huge/var/scrub_id = "generic"

/obj/machinery/computer/area_atmos/tag
	name = "Heavy Scrubber Control"
	zone = "This computer is operating industrial scrubbers nearby."
	var/scrub_id = "generic"
	var/last_scan = 0

/obj/machinery/computer/area_atmos/tag/scanscrubbers()
	if(last_scan && world.time - last_scan < 20 SECONDS)
		return 0
	else
		last_scan = world.time

	connectedscrubbers.Cut()

	for(var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber in world)
		if(scrubber.scrub_id == src.scrub_id)
			connectedscrubbers += scrubber

	src.updateUsrDialog()

/obj/machinery/computer/area_atmos/tag/validscrubber(var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber)
	if(scrubber.scrub_id == src.scrub_id)
		return 1

	return 0
