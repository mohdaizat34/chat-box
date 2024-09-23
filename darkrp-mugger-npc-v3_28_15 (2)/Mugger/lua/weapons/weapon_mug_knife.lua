--// Phony knife because I needed an entity a knife world model and this is what I whipped up

if CLIENT then
	SWEP.PrintName			= "Knife"

	killicon.AddFont("weapon_mug_knife", "CSKillIcons", "j", Color( 255, 80, 0, 255 ))
	surface.CreateFont("CSKillIcons", {font = "csd", size = ScreenScale(30), weight = 500, antialias = true, additive = true})
	surface.CreateFont("CSSelectIcons", {font = "csd", size = ScreenScale(60), weight = 500, antialias = true, additive = true})
end

SWEP.Spawnable					= false
SWEP.AdminSpawnable				= false

SWEP.HoldType 					= "knife"
SWEP.ViewModel 					= "models/weapons/v_knife_t.mdl"
SWEP.WorldModel 				= "models/weapons/w_knife_t.mdl" 

SWEP.Weight						= 5
SWEP.AutoSwitchTo				= false
SWEP.AutoSwitchFrom				= false

SWEP.Primary.ClipSize			= -1
SWEP.Primary.Damage				= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo				="none"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo				="none"

function SWEP:PrimaryAttack()
	self.Owner:ChatPrint("What are you doing with this! This is a mugger's knife!")
end

function SWEP:SecondaryAttack()

end

