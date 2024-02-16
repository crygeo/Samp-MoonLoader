
function EXPORTS.creditos()
	local x, y = getScreenResolution()
    local x = x / 2
    local y = x / 2
    local x = x - 270
    local y = y - 110
	local dxut = dxutCreateDialog("{FFFF00}Timer{0000FF} Ti{FF00FF}en{00FFFF}das")
	dxutSetDialogPos(dxut, x,y,555,250)
	dxutSetDialogVisible(dxut, true)
	dxutEnableDialogCaption(dxut, true)
	dxutSetDialogMinimized(dxut, false)
	dxutSetDialogBackgroundColor(dxut, 0xFF000000)
	dxutAddStatic(dxut, 188, "{FF9D00}> {FFFFFF} Gracias por descargar este Mod!", 5, 0, 500, 20)
	dxutAddStatic(dxut, 189, "{FF9D00}> {FFFFFF} Si encuentras algún error, reportarlo.", 5, 25, 500,20)
	dxutAddStatic(dxut, 190, "{FF9D00}> {FFFFFF} Creditos:", 5, 50, 500,20)
	dxutAddStatic(dxut, 191, "{FF9D00}> {FFFFFF} Discord:{00FF00} Samp Mods{FFFFFF} discord.com/invite/nCUrj2W", 5, 75, 500,20)
	dxutAddStatic(dxut, 200, "{FF9D00}> {FFFFFF} Youtube: {00FF00} Jose Samp {FF9D00} {FFFFFF} www.youtube.com/JoseSampMods/videos", 5, 100, 550,20)
	dxutAddStatic(dxut, 201, "{FF9D00}> {FFFFFF} Testers: Julian, Martin, Padd", 5,125,500,20)
	playMissionPassedTune(1)
	wait(10000)
	dxutDeleteDialog(dxut)
end