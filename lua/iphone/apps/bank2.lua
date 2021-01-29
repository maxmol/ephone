local L = include('iphone/translation.lua')

local bank_action = function(window, panel, page, action)
	function panel:Paint(w, h)
		draw.SimpleText(page == 2 and L'bank_withdraw' or L'bank_deposit', 'iphone_contact_bold', 16, 20, color_black)
	end

	local input = vgui.Create('DButton', panel)
	input:SetPos(16, 60)
	input:SetSize(350-32, 80)
	input.value = 0

	function input:Paint(w, h)
		iPhone.cursorUpdate(self)

		draw.RoundedBox(16, 0, 0, w, h, Color(233, 244, 251))

		render.ClearStencil()
		render.SetStencilEnable(true)

		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)

		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_ZERO)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
		render.SetStencilReferenceValue(1)

			surface.DrawRect(2, 2, w - 4, h - 4)

		render.SetStencilFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilReferenceValue(1);

		local text = DarkRP.formatMoney(tonumber(self.value) or 0)

		surface.SetFont('iphone_large')
		local tw = surface.GetTextSize(text)
		if tw > w-20 then
			draw.SimpleText(text, 'iphone_large', w - 4, h / 2, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(text, 'iphone_large', w / 2, h / 2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		render.SetStencilEnable(false)
		render.ClearStencil()

		return true
	end

	function input:DoClick()
		self.value = 0

		local entry = vgui.Create('DTextEntry')
		entry:SetSize(ScrW(), ScrH())
		entry:MakePopup()
		entry:SetAlpha(0)
		entry:SetUpdateOnType(true)

		function entry:AllowInput(char)
			local charCode = string.byte(char)
			if charCode < string.byte('0') or charCode > string.byte('9') or self:GetValue():len() > 12 then
				return true
			end
		end

		entry.OnChange = function(entry)
			self.value = entry:GetValue()
		end

		entry.OnLoseFocus = function()
			entry:Remove()
			self.textEntry = nil
		end
		entry.OnMousePressed = entry.OnLoseFocus
		self.textEntry = entry
	end

	local btnMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/top_button.png', function(mat)
		btnMat = mat
	end)

	local b = vgui.Create('DButton', panel)
	b:SetSize(302, 63)
	b:SetPos((panel:GetWide() - b:GetSize()) / 2, panel:GetTall() - b:GetTall() - 42)
	function b:Paint(w, h)
		iPhone.cursorUpdate(self)

		if btnMat then
			surface.SetMaterial(btnMat)
			if self.Hovered then
				surface.SetDrawColor(200, 200, 200)
			else
				surface.SetDrawColor(255, 255, 255)
			end

			surface.DrawTexturedRect(0, 0, w, h)

			draw.SimpleText(L('bank_btn' .. page), 'iphone_call', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		return true
	end

	function b:DoClick()
		action(tonumber(input.value) or 0)
		timer.Simple(0.3, function()
			if IsValid(window) then
				iPhone.appSwitch(window, iPhone.apps['bank1'])
			end
		end)
	end
end

App.bank_action = bank_action

App.init = function(window)
	local panel = iPhone.apps['bank1'].bank_main(window, 2)
	bank_action(window, panel, 2, function(amount)
		if amount > 0 then
			net.Start('iphone_bank')
			net.WriteUInt(2, 3)
			net.WriteUInt(amount, 32)
			net.SendToServer()
		end
	end)
end