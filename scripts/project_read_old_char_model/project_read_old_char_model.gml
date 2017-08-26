/// project_read_old_char_model(index)
/// @arg index
/*
var n = argument0;

switch (n)
{
	case 0: return "characterhuman"
	case 1: return "characterzombie"
	case 2: return "characterskeleton"
	case 3: return "charactercreeper"
	case 4: return "characterspider"
	case 5: return "characterenderman"
	case 6: return "characterslime"
	case 7: return "characterghast"
	case 8: return "characterzombiepigman"
	case 9: return "characterchicken"
	case 10: return "charactercow"
	case 11: return "charactermooshroom"
	case 12: return "characterpig"
	case 13: return "charactersheep"
	case 14: return "charactersquid"
	case 15: return "charactervillager"
	case 16: return "characterocelot"
	case 17: return "characterwolf"
	case 18: return "characterirongolem"
	case 19: return "charactersnowman"
}

switch (load_format) 
{
	case project_05:
		if (n = 20) // Pyroland baby
			return "characterhuman"
		if (n = 21) // Balloonicorn
			return "characterpig"
		break
		
	case project_06:
	case project_07demo:
		switch (n)
		{
			case 20: return "charactersilverfish"
			case 21: return "characterbat"
			case 22: return "characterzombievillager"
			case 23: return "characterwitch"
			case 24: return "charactercavespider"
			case 25: return "characterwitherskeleton"
			case 26: return "characterwither"
			case 27: return "characterhuman" // Pyroland baby
			case 28: return "characterpig" // Balloonicorn
			case 29: return "specialblockchest"
			case 30: return "specialblocklargechest"
			case 31: return "specialblocklever"
			case 32: return "specialblockpiston"
			case 33: return "specialblockstickypiston"
			case 34: return "specialblockarrow"
			case 35: return "specialblockboat"
			case 36: return "specialblockminecart"
		}
		break
		
	default: // 1.0.0 demos
		switch (n)
		{
			case 20: return "charactersilverfish"
			case 21: return "characterbat"
			case 22: return "characterzombievillager"
			case 23: return "characterwitch"
			case 24: return "charactercavespider"
			case 25: return "characterwitherskeleton"
			case 26: return "characterwither"
			case 27: return "characterblaze"
			case 28: return "charactermagmacube"
			case 29: return "characterhorse"
			case 30: return "characterdonkey"
			case 31: return "characterenderdragon"
			case 32: return "specialblockchest"
			case 33: return "specialblocklargechest"
			case 34: return "specialblocklever"
			case 35: return "specialblockpiston"
			case 36: return "specialblockstickypiston"
			case 37: return "specialblockarrow"
			case 38: return "specialblockboat"
			case 39: return "specialblockminecart"
			case 40: return "specialblockenchantmenttable"
			case 41: return "specialblocksignpost"
			case 42: return "specialblockwallsign"
			case 43: return "specialblockboat" // Wooden door
			case 44: return "specialblockboat" // Iron door
			case 45: return "specialblockboat" // Trapdoor
			case 46: return "specialblockendercrystal"
			case 47: return "specialblockcamera"
		}
		break
}
return ""
*/