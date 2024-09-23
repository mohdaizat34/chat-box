----// GTA Mugger //----
-- Author: Exho

mugger = {}
mugger.version = "3/28/16"

mugger.config = {
	
	-- When the mugger is not on a job, should he randomly walk around the map?
	wanderWhenIdle = false,
	-- When the mugger is not on a job, should be walk along a predetermined path?
	wanderAlongPath = false,
	
	-- How much it costs to hire a mugger
	hireCost = 200,
	-- Whether or not you get your money refunded if the mugger fails
	refunds = true,
	
	-- Mugger's normal health
	health = 100,
	-- Seconds after each mugging where the mugger is unusable
	cooldownTime = 10,
	
	-- Minimum amount of money to steal
	minMoneyStolen = 100,
	-- Maximum amount of money to steal
	maxMoneyStolen = 500,
	
	-- Should players take damage when mugged?
	takeDamage = true,
	-- Minimum amount of damage taken
	minDamage = 5,
	-- Maximum amount of damage taken
	maxDamage = 15,
	
	-- How far away can the player see the mugger's name and health
	targetIDRange = 500,
	-- Show the mugger's health when the player looks at him
	targetIDHealth = true,
	-- Shows "the Mugger" at the end of the mugger's name when the player looks at him
	targetIDSuffix = true,
	-- How long (seconds) for the mugger to hunt his target
	maxSearchTime = 80,
	-- Max distance (source units) for the mugger to be able to target someone
	maxRange = 4000,
	-- Can the mugger chase people down who are in vehicles?
	canTargetVehicles = true,
	
	-- Should muggers respawn after being killed?
	shouldRespawn = true,
	-- Time after the mugger is killed until another one spawns
	respawnDelay = 15,
	-- Seconds in which a mugged player is incapacitated
	downTime = 3,
	
	-- How fast the mugger runs when he chases a guy
	chaseSpeed = 350,
	-- Mugger acceleration
	chaseAcceleration = 500,
	
	-- How fast the mugger runs when he has mugged a guy
	fleeSpeed = 350,
	-- Mugger acceleration
	fleeAcceleration = 600,
	
	-- Names that the mugger could be named
	names = {
		"Angelo",
		"Ben",
		"Carlos",
		"Cedric",
		"Franco",
		"Frank",
		"Joey",
		"Mario",
		"Tommy",
		"TJ",
		"Tyrone",
		"Samuel",
		"Vinny",
		"Victor",
	},
	
	-- Models that the mugger can use
	models = {
		"models/humans/group01/male_01.mdl",
		"models/humans/group01/male_02.mdl",
		"models/humans/group01/male_03.mdl",
		"models/humans/group01/male_04.mdl",
		"models/humans/group01/male_05.mdl",
		"models/humans/group01/male_06.mdl",
		"models/humans/group01/male_07.mdl",
		"models/humans/group01/male_08.mdl",
		"models/humans/group01/male_09.mdl",
	},
	
	--// Config tables - Leave blank for all groups/jobs - Case insensitive 
	
	-- Player jobs that are able to hire the mugger
	useableJobs = {
		
	
	},
	
	-- Usergroups that can hire the mugger
	useableUsergroups = {
	
	},
	
	-- Player jobs that are unable to be targeted by the mugger
	unTargetableJobs = {
		
	},
	
	-- Usergroups are unable to be targeted by the mugger
	unTargetableUsergroups = {
		
	},
	
	-- Usergroups that have admin privileges such as viewing the logs, spawning or removing muggers
	adminUsergroups = {
		"superadmin",
		"owner",
	},
	
	-- Usergroups that can view the mugger log - Leave blank to inherit from adminUsergroups
	canViewLogUsergroups = {
		
	},
	
	debug = false,
}

--// Spawnpoints for the mugger for each map
-- Generate these by standing where you want and typing "mypos" in console, copy what it prints into this table
-- Alternatively, use the mugger spawn tool to add multiple muggers and hit your 'Reload' key to print the code into console
mugger.spawnpoints = {
	-- 1 mugger
	["gm_flatgrass"] = Vector( 25, -75, -12287 ),
	
	-- Multiple muggers
	["gm_flatgrass"] = {
		Vector( 25, -75, -12287 ),
		Vector( 95, -75, -12287 ),
		Vector( 165, -75, -12287 ),
	},

}

--// Points for the mugger to wander around to when he is not busy
-- Generate these by giving yourself a 'weapon_vector' and going around right clicking at the positions you want the mugger to move to
-- The mugger will walk and cycle through each of these vectors in the order they appear
mugger.path = {
	["gm_flatgrass"] = {
		Vector( -14, 28, -12287 ),
		Vector( 1, -162, -12287 ),
		Vector( 131, -163, -12287 ),
		Vector( 159, 11, -12287 ),
	},

}

if SERVER then
	util.AddNetworkString("mug_panel")
	util.AddNetworkString("mug_send")
	util.AddNetworkString("mug_notify")
	util.AddNetworkString("mug_spawn")
	util.AddNetworkString("mug_chat")
	util.AddNetworkString("mug_getlog")
	util.AddNetworkString("mug_free")
	
	AddCSLuaFile()
	AddCSLuaFile("mugger/cl_mugger.lua")
	
	include("mugger/sv_mugger.lua")
	mugger.checkUpdate()
end

if CLIENT then
	include("mugger/cl_mugger.lua")
	language.Add("mugger", "Mugger")
	language.Add("undone_mugger", "Undone Mugger")
end

