local PANEL = {}

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH()

	self:SetSize(scrW, scrH)
	self:SetPos(0, 0)

	local text = string.utf8upper(L("bleedingOut"))

	surface.SetFont("ixMenuButtonHugeFont")
	local textW, textH = surface.GetTextSize(text)

	self.label = self:Add("DLabel")
	self.label:SetPaintedManually(true)
	self.label:SetAlpha(255)
	self.label:SetPos(scrW * 0.5 - textW * 0.5, scrH * 0.5 - textH * 0.5)
	self.label:SetFont("ixMenuButtonHugeFont")
	self.label:SetText(text)
	self.label:SetTextColor(Color( 255, 0, 0))
	self.label:SizeToContents()

end

function PANEL:Paint(width, height)
	surface.SetDrawColor(0, 0, 0, 205)
	surface.DrawRect(0, 0, width, height)
	self.label:PaintManual()
end

vgui.Register("BleedingScreen", PANEL, "Panel")
