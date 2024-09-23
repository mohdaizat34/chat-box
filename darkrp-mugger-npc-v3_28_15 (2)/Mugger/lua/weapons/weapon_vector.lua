if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName 			= "Vector Tracker"
SWEP.Author				= "Exho"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= "Left click to place vector, right click to remove vector, reload to print to console"

SWEP.Slot				= 3
SWEP.SlotPos			= 1
SWEP.DrawAmmo 			= false
SWEP.DrawCrosshair 		= true
SWEP.HoldType			= "normal"
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true


SWEP.ViewModel           = "models/weapons/v_pistol.mdl"
SWEP.WorldModel          = "models/weapons/w_pistol.mdl"
SWEP.ViewModelFlip		 = false

SWEP.points = {}

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	local tr = self.Owner:GetEyeTrace()
	
	-- Add a point
	table.insert( self.points, tr.HitPos )
end

function SWEP:SecondaryAttack()
	local tr = self.Owner:GetEyeTrace()
	local pos = tr.HitPos
	
	-- Remove points close to where we right clicked
	for k, v in pairs( self.points ) do
		if v:Distance( pos ) < 10 then
			table.remove( self.points, k )
		end
	end
end

function SWEP:Reload()
	if SERVER then return end
	if not IsFirstTimePredicted() then return end
	
	-- Print all the points to console as a table of vectors
	print( string.format( '["%s"] = {', game.GetMap() ) )
	for _, pos in pairs( self.points ) do
		print( string.format( '\tVector( %s, %s, %s ),', pos.x, pos.y, pos.z ) )
	end
	print("},")
end

function SWEP:DrawHUD()
	local ID = Material( "cable/redlaser" )
	hook.Add( "PostDrawOpaqueRenderables", "vector_connector", function()
		if not self.points or #self.points == 0 then return end
		
		for i = 1, #self.points do
			local pos = self.points[i] 
			local pos2 = Vector( 0, 0, 0 )
			
			-- Either draw the beam to the next point or back to the start
			if self.points[i+1] then
				pos2 = self.points[i+1]
			else
				pos2 = self.points[1]
			end
			
			-- Draw a beam across each point
			render.SetMaterial( ID )
			render.DrawBeam( pos, pos2, 30, 0, 3, Color(255,255,255) )
			
			-- Draw a beam showing where this point is
			render.SetMaterial( ID )
			render.DrawBeam( pos, pos + Vector( 0, 0, 20 ), 30, 0, 3, Color(0,255,255) )
		end
	end)
end


