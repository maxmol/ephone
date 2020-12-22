App.name = 'Maps'
App.noTitle = true
App.icon = 'map_appli_icon'
App.pos_x = 250
App.pos_y = 628
App.bgColor = Color(30, 30, 31)
App.homeBarColor = Color(200, 200, 200)

local overview = {
	scale = 29.2,
	h = 1108,
	w = 1149,
	pos_x = -16304,
	pos_y = 16654,
}

App.init = function(window)
	local mapMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/map.png', function(mat)
		mapMat = mat
	end)

	local p = vgui.Create('Panel', window)
	p:SetSize(window:GetWide(), window:GetTall() - 80)
	p:SetPos(0, 30)
	p.mapx = 0
	p.mapy = 0

	local function mapPos(worldPos)
		return p.mapx + (worldPos.x - overview.pos_x)/overview.scale + p:GetWide()/2,
				p.mapy + (overview.pos_y - worldPos.y)/overview.scale + p:GetTall()/2
	end
	function p:Paint(w, h)
		if not mapMat then return end
		
		iPhone.cursorUpdate(self)

		render.ClearStencil()
		render.SetStencilEnable(true)

		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)

		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_ZERO)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
		render.SetStencilReferenceValue(1)

			surface.SetDrawColor(255, 255, 255)
			surface.DrawRect(0, 0, w, h)

		render.SetStencilFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilReferenceValue(1);

			surface.SetMaterial(mapMat)

			local pos = LocalPlayer():GetPos()
			local x, y = pos.x, pos.y
			local addX, addY = 0, 0
			if self.mouseDown then
				if not self.mx then
					self.mx = gui.MouseX()
					self.my = gui.MouseY()
				end

				addX = (gui.MouseX() - self.mx) * 0.0107
				addY = (gui.MouseY() - self.my) * 0.0107

				if not input.IsMouseDown(MOUSE_LEFT) and not input.IsMouseDown(MOUSE_RIGHT) then
					self:OnMouseReleased()
				end
			end

			local realMapX = (overview.pos_x - x)/overview.scale + addX
			local realMapY = (y - overview.pos_y)/overview.scale + addY
			self.mapx = Lerp(FrameTime() * 6, self.mapx, realMapX)
			self.mapy = Lerp(FrameTime() * 6, self.mapy, realMapY)

			surface.DrawTexturedRect(self.mapx + w/2, self.mapy + h/2, overview.w, overview.h)
			
			local plyX, plyY = w/2 + self.mapx - realMapX + addX, h/2 + self.mapy - realMapY + addY
			surface.DrawCircle(plyX, plyY, 4, 100, 150, 255)
			local a = math.rad(LocalPlayer():EyeAngles().y + 90)
			surface.DrawLine(plyX, plyY, plyX + math.sin(a) * 20, plyY + math.cos(a) * 20)

			local target = iPhone.hitman_target
			if IsValid(target) then
				surface.SetDrawColor(255, 64, 64)
				local target_x, target_y = mapPos(target:GetPos())
				surface.DrawRect(target_x, target_y, 8, 8)
				draw.SimpleText('Cible', 'iphone_appname', target_x, target_y - 22, Color(255, 64, 64))
			end
	end

	function p:PaintOver()
		render.SetStencilEnable(false)
		render.ClearStencil()
	end

	function p:OnMousePressed()
		self.mx = nil
		self.my = nil
		self.mouseDown = true
	end

	function p:OnMouseReleased()
		self.mouseDown = false
	end
end