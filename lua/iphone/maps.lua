App.name = 'Maps'
App.noTitle = true
App.icon = 'map_appli_icon'
App.pos_x = 250
App.pos_y = 628
App.bgColor = Color(96, 96, 96)
App.homeBarColor = Color(200, 200, 200)

local overview = {
	scale = 10,
	pos_x = -1000,
	pos_y = -1000,
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
	function p:Paint(w, h)
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

			local realMapX = (x - overview.pos_x)/overview.scale + addX
			local realMapY = (overview.pos_y - y)/overview.scale + addY
			self.mapx = Lerp(FrameTime() * 6, self.mapx, realMapX)
			self.mapy = Lerp(FrameTime() * 6, self.mapy, realMapY)

			surface.DrawTexturedRect(self.mapx, self.mapy, h * 4, h * 4)
			
			local plyX, plyY = w/2 + self.mapx - realMapX + addX, h/2 + self.mapy - realMapY + addY
			surface.DrawCircle(plyX, plyY, 4, 100, 150, 255)
			local a = math.rad(LocalPlayer():EyeAngles().y - 90)
			surface.DrawLine(plyX, plyY, plyX + math.sin(a) * 20, plyY + math.cos(a) * 20)
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