include('shared.lua')

AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel() 
	vm:ResetSequence(0)
	vm:SetPlaybackRate(0)
end