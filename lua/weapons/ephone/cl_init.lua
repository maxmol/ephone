include('shared.lua')

SWEP.PrintName = 'ePhone'
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.Purpose = ''
SWEP.Author = 'ePhone Team'
SWEP.UseHands = true

SWEP.HoldType = 'pistol'
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 90
SWEP.BobScale = 0.05

function SWEP:Holster()
	if self.Owner ~= LocalPlayer() then return end
	if IsValid(iPhone.panel) then iPhone.panel:SetVisible(false) end
end

local cursor_x, cursor_y = 0, 0
local last_hovered_panel
local function cursorUpdate(panel, custom_w, custom_h)
	if not IsValid(iPhone.panel2d) then return end

	local x, y = panel:LocalToScreen(0, 0)
	local w, h = panel:GetSize()
	w = custom_w or w
	h = custom_h or h

	local hovered = cursor_x > x and cursor_y > y and cursor_x < x + w and cursor_y < y + h
	if hovered then
		last_hovered_panel = panel
		if not panel.Hovered then
			panel.Hovered = true
			if panel.OnCursorEntered then panel:OnCursorEntered() end
		end
	elseif panel.Hovered then
		panel.Hovered = false
		if panel.OnCursorExited then panel:OnCursorExited() end
	end
end

if iPhone then
	iPhone.cursorUpdate = cursorUpdate
end

hook.Add('iPhoneInitialized', 'cursorUpdate', function(iPhone)
	iPhone.cursorUpdate = cursorUpdate
end)

function SWEP:PostDrawViewModel(vm)
	if self.Owner ~= LocalPlayer() then return end

	self.ViewModelFOV = LocalPlayer():GetFOV()
	local ang = vm:GetAngles()
	local realAng = Angle(ang)


	ang:RotateAroundAxis(ang:Right(), 68)
	ang:RotateAroundAxis(ang:Forward(), -13.5)
	ang:RotateAroundAxis(ang:Up(), -94.1)

	local pos = vm:GetPos() +
		realAng:Up() * 0.18 + realAng:Right() * 4.05 + realAng:Forward() * 21.7

	local size = 0.0107

	local cursorWorldPos = util.IntersectRayWithPlane(LocalPlayer():GetShootPos(),
		gui.ScreenToVector(gui.MousePos()), pos, ang:Up())

	if not cursorWorldPos then return end
	local cursor_pos = WorldToLocal(cursorWorldPos, Angle(0,0,0), pos, ang)

	cursor_x = cursor_pos.x / size
	cursor_y = -cursor_pos.y / size

	local oldMouseX = gui.MouseX
	local oldMouseY = gui.MouseY

	function gui.MouseX()
		return (cursor_x or 0) / size
	end

	function gui.MouseY()
		return (cursor_y or 0) / size
	end

	iPhone.createScreen()
	iPhone.panel:SetVisible(true)
	cam.Start3D2D(pos, ang, size)
		iPhone.panel:PaintManual()
	cam.End3D2D()

	gui.MouseX = oldMouseX
	gui.MouseY = oldMouseY
end

function SWEP:GetViewModelPosition(eyePos, eyeAng)
	if self.Owner ~= LocalPlayer() then return end
	eyeAng:RotateAroundAxis(eyeAng:Right(), 15)
	return eyePos - eyeAng:Forward() * 10 - eyeAng:Right() * 1, eyeAng
end

local cursorMaterial = Material('vgui/slider')
function SWEP:PrimaryAttack()
	if self.Owner ~= LocalPlayer() then return end

	gui.EnableScreenClicker(true)
	RestoreCursorPosition()

	if IsValid(iPhone.panel2d) then
		iPhone.panel2d:Remove()
	end

	local p = vgui.Create('EditablePanel')
	p:SetSize(ScrW(), ScrH())
	p:SetCursor('blank')
	function p:Paint()
		surface.SetMaterial(cursorMaterial)
		surface.SetDrawColor(255, 255, 255, 220)
		surface.DrawTexturedRect(gui.MouseX() - 8, gui.MouseY() - 8, 16, 16)
	end

	function p:OnMousePressed(code)
		if IsValid(last_hovered_panel) and last_hovered_panel.Hovered then
			if last_hovered_panel.OnMousePressed and not last_hovered_panel.CursorDisabled then
				last_hovered_panel:OnMousePressed(code)
			end
		else
			RememberCursorPosition()
			gui.EnableScreenClicker(false)
			self:Remove()
		end
	end

	function p:OnMouseReleased(code)
		if IsValid(last_hovered_panel) and last_hovered_panel.Hovered then
			if last_hovered_panel.OnMouseReleased and not last_hovered_panel.CursorDisabled then
				last_hovered_panel:OnMouseReleased(code)
			end
		end
	end

	function p:OnMouseWheeled(wheel)
		if IsValid(last_hovered_panel) and last_hovered_panel.Hovered then
			local p = last_hovered_panel
			while true do
				if not IsValid(p) then break end
				if p.OnMouseWheeled then
					p:OnMouseWheeled(wheel)
					break
				end
				p = p:GetParent()
			end
		end
	end

	iPhone.panel2d = p
end

SWEP.SecondaryAttack = SWEP.PrimaryAttack

function SWEP:Reload()
	if self.reloaded and self.reloaded > SysTime() then return end

	self.reloaded = SysTime() + 1
	if IsValid(iPhone.panel2d) then
		iPhone.panel2d:Remove()
		gui.EnableScreenClicker(false)
	end

	if IsValid(iPhone.panel) then
		iPhone.panel:Remove()
	end
end