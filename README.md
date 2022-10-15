# Pill Crusher API

Pill Crusher provides a small API that allows you to add crusher effects to your modded pill effects.
 
You can access the api via the PillCrusher global and it provides 3 functions:
	-PillCrusher:AddPillCrusherEffect(pillEffect, name, func): Main function you'll use, it registers a pill effect. Name is the name that will be displayed when the pill is crushed and func is a function with the following parameters: funct(player: EntityPlayer, rng: RNG, isGolden: boolean, isHorse: boolean, pillColor: PillColor).
	-PillCrusher:HasCrushedPill(pillEffect): Returns true if the given pill effect was crushed in the current room.
	-PillCrusher:GetCrushedPillNum(pillEffect): Returns the number of times a pill effect was crushed in the current room.
