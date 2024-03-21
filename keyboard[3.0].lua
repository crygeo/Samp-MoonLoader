script_author('CaJlaT')
script_name('Keyboard & Mouse')
script_version('3.0')
local wm = require('lib.windows.message')
local inicfg = require 'inicfg'
local res, imgui = pcall(require, 'mimgui') assert(res, '������, ���������� mimgui - https://www.blast.hk/threads/66959/')
local res, ti = pcall(require, 'tabler_icons') assert(res, '������, ���������� tabler-icons - https://www.blast.hk/threads/94826/')
local mLoad, monet = pcall(require, 'MoonMonet') if not mLoad then print('��� ����������������� ���� "MoonMonet", ���������� - https://www.blast.hk/threads/105945/') end
local ffi = require 'ffi'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local iniFile = 'keyboard.ini'
local ini = inicfg.load({
	config = {
		active = false,
		mode = 0,
		move = true,
		theme = 0,
		rounding = true,
		size = 1.0
	},
	mouse = {
		active = false,
		x = 10,
		y = 200,
		size = 1.0,
		move = true
	},
	pos = {
		x = 10,
		y = 500
	},
	cStyle = {
		mainColor = 0xcc000000,
		activeColor = 0xcc993066,
		borderColor = 0xff993066,
		textColor = 0xffffffff
	},
	monet = {
		mainColor = 0xcc993066,
		brightness = 1.0
	},
	rainbowMode = {
		active = false,
		speed = 1.0,
		async = false
	}
}, iniFile)
if not doesFileExist('moonloader/config/'..iniFile) or not ini.cStyle or not ini.monet then print('Creating/updating the .ini file') inicfg.save(ini, iniFile) end

local keyboardsDir = getWorkingDirectory().."\\config\\keyboards.json"
function json(filePath)
	local f = {}

	function f:read()
		local f = io.open(filePath, "r+")
		local jsonInString = f:read("*a")
		f:close()
		local jsonTable = decodeJson(jsonInString)
		return jsonTable
	end

	function f:write(t)
		f = io.open(filePath, "w")
		f:write(encodeJson(t))
		f:flush()
		f:close()
	end

	return f
end
local kayboardsUrl = 'https://raw.githubusercontent.com/TheCaJlaT/TheCaJlaT/lua/keyboards.json'
local keyboards = {}


local settings = new.bool(false)
local keyboard = new.bool(ini.config.active)
local mouse = new.bool(ini.mouse.active)
local keyboard_type = new.int(ini.config.mode)
local keyboardMove = new.bool(ini.config.move)
local mouseMove = new.bool(ini.mouse.move)
local kPos = imgui.ImVec2(ini.pos.x, ini.pos.y)
local mPos = imgui.ImVec2(ini.mouse.x, ini.mouse.y)
local theme = new.int(ini.config.theme)
local rounding = new.bool(ini.config.rounding)
local kSize = new.float(ini.config.size)
local mSize = new.float(ini.mouse.size)

local cStyle = {} -- ����� ��� ��������
local cStyleEdit = {} -- ����� ��� ColorEdit
local monetColor = imgui.ImVec4(0,0,0,0)
local monetColorEdit = new.float[4](0, 0, 0, 0)
local monetBrightness = new.float(ini.monet.brightness)
local rainbowMode = {
	active = new.bool(ini.rainbowMode.active),
	speed = new.float(ini.rainbowMode.speed),
	async = new.bool(ini.rainbowMode.async)
}

local themesList = {
	arr = {
		u8'������', 
		u8'�������', 
		u8'���������', 
		u8'����������', 
		u8'��������', 
		u8'Ƹ����', 
		u8'����',
		u8'MoonMonet'
	},
	var = nil
}
themesList.var = new['const char*'][#themesList.arr](themesList.arr)

local keyboardList = { arr =  {}, var = nil}
local keysList = { arr = {}, var = nil}
local addKey = {
	state = new.bool(false), 
	selected = new.int(0),
	block = 0,
	line = 0
}
local addLine = false
local editElement = {
	state = new.bool(false),
	selected = new.int(0),
	block = 0,
	line = 0,
	key = 0,
	tKey = 0,
	keySize = {x = new.int(20), y = new.int(20)}
}

local wheel = {} -- ���� ����������� �������� ������
local gta = true -- ���� �������� � ����� ������� ���� ��� ������������

function main()
	return(".... No desavilitado") -- Comenta esa linea para usar
	while not isSampAvailable() do wait(100) end
	getKeyboardsList()
	printChat('������ �������� � ����� � ������. �����: CaJlaT')
	sampRegisterChatCommand('keyboard1', function() settings[0] = not settings[0] end)
	while true do wait(0)
		local delta = getMousewheelDelta()
		if mouse[0] and delta ~= 0 then table.insert(wheel, {delta, os.clock()+0.05}) end -- ���� ����������� �������� ������
	end
end

function printChat(text) sampAddChatMessage(string.format('[{993066}%s v.%s{FFFFFF}]: %s', thisScript().name, thisScript().version, text), -1) end


function loadFonts(sizes)
	local fonts = {}
	local config = imgui.ImFontConfig()
	local iconfig = imgui.ImFontConfig()
	iconfig.MergeMode = false
	config.MergeMode = true
	config.PixelSnapH = true
	local iconRanges = imgui.new.ImWchar[3](ti.min_range, ti.max_range, 0)
	imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(ti.get_font_data_base85(), 14, config, iconRanges) -- �����������
	for i, v in ipairs(sizes) do
		fonts[v] = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', v, iconfig, glyph_ranges)
		imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(ti.get_font_data_base85(), v, config, iconRanges)
	end
	return fonts
end

local fonts = {}

imgui.OnInitialize(function()
	local getfloat = function(r, g, b, a) return r/255, g/255, b/255, a/255 end
	for k, v in pairs(ini.cStyle) do
		local a, r, g, b = getfloat(explode_argb(ini.cStyle[k]))
		cStyle[k] = imgui.ImVec4(r, g, b, a)
		cStyleEdit[k] = new.float[4](r, g, b, a)
	end
	local a, r, g, b = getfloat(explode_argb(ini.monet.mainColor))
	monetColor = imgui.ImVec4(r, g, b, a)
	monetColorEdit = new.float[4](r, g, b, a)
	imgui.GetIO().IniFilename = nil
	defaultStyle()
	if mLoad and theme[0] == 7 then
		theme[0] = 6
		print('��� ����������������� ���� "MoonMonet", ���������� - https://www.blast.hk/threads/105945/')
		printChat('{FF0000}������, � ��� �� ����������� ���������� "MoonMonet", ���� ���� �������� �� "����"')
		printChat('��� ����������������� ���� "MoonMonet", ���������� - https://www.blast.hk/threads/105945/')
		printChat('������ ����������� � ����� ������')
		setClipboardText('https://www.blast.hk/threads/105945/')
	end
	glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    fonts = loadFonts({60, 16})
	styles[theme[0]]()
	keyColors = setKeyColors()
end)

local sX, xY = getScreenResolution()


local nav = {
    sel = new.int(1),
    list = { 
        {name = u8'����������', icon =  ti.ICON_INFO_CIRCLE}, 
        {name = u8'����������', icon =  ti.ICON_KEYBOARD}, 
        {name = u8'����', icon =  ti.ICON_MOUSE}, 
        {name = u8'����', icon =  ti.ICON_PALETTE}, 
        {name = u8'���� ����������', icon =  ti.ICON_VECTOR}
    }
}

-- ����������
imgui.OnFrame(function() return keyboard[0] and not isGamePaused() and gta and #keyboards > 0 end, function(player)
	player.HideCursor = not settings[0]
	imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(5.0, 2.4)) -- ���� ��������� ������
	imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0,0,0,0)) -- ������� ���
	imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0.0) -- ������� ������� ����
	imgui.SetNextWindowPos(kPos, imgui.Cond.FirstUseEver, imgui.ImVec2(0, 0))
	imgui.Begin('##keyboard', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + (keyboardMove[0] and 0 or imgui.WindowFlags.NoMove) )
		kPos = imgui.GetWindowPos()
		imgui.SetWindowFontScale(kSize[0])
		local spacing = imgui.GetStyle().ItemSpacing
		for ib, block in ipairs(keyboards[keyboard_type[0]+1].keyboard.blocks) do
			imgui.BeginGroup()
			for il, line in ipairs(block) do
				local y = imgui.GetCursorPosY()
				if #line == 0 then imgui.NewLine() else
					for i, key in ipairs(line) do
						if key.pos then
							local x = imgui.GetCursorPosX()
							imgui.SetCursorPosX((x+20*(kSize[0])*(key.pos-1))+spacing.x*key.pos-1)
						end
						if not key.time then key.time = -1 end
						if isKeyDown(key.id) then key.time = os.clock() + 0.015 end
						renderKey(key)
						if i ~= #line then
							imgui.SameLine()
						end
					end
				end
				imgui.SetCursorPosY(y+20*kSize[0]+spacing.y)
			end
			imgui.EndGroup()
			imgui.SameLine()
		end
	imgui.End()
	imgui.PopStyleColor()
	imgui.PopStyleVar(2)
end)

-- ���������
imgui.OnFrame(function() return settings[0] and not isGamePaused() and gta and #keyboards > 0 end, function(player)
	player.HideCursor = not settings[0]
	local X, Y = getScreenResolution()
	imgui.SetNextWindowSize(imgui.ImVec2(822, 465), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin(u8'���������', settings, imgui.WindowFlags.NoTitleBar)
		imgui.DrawMenu(nav)
		imgui.SameLine()
		imgui.BeginChild('##main', imgui.ImVec2(0, 0), true)
			local y = imgui.GetCursorPosY()
			if nav.sel[0] == 1 then
				imgui.PushFont(fonts[16])
				imgui.Text(u8'�����������, ��� ����� ���� �������� �������.')
				imgui.Text(u8'? ������ ���� �������� ������ ������ ����?')
				imgui.Text(u8'- � ������ �� ���� �� �������� ���������� � ���-���� �� ��������� ������ ����')
				imgui.Text(u8'? ������ ��� ��������� ������� ����� �������?')
				imgui.Text(u8'- ������� ����������� ������� ��������� ������� ������ � �� ����� :(')
				imgui.NewLine()
				imgui.Text(u8'������ ������ ��������� � ���������� 3.0:')
				imgui.Text(u8'* �������� �������� �������, ������� �� mimgui')
				imgui.Text(u8'* ��������� ������ ������� ������')
				imgui.Text(u8'* ��������� 2 ������������ ���� ("����" � "MoonMonet")')
				imgui.Text(u8'* ��������� ����������� �������� ����� �������������� ������� ������')
				imgui.Text(u8'* �������� �������� ����������')
				imgui.Text(u8'* ��������� ����������� ������ ������ ���������� � ����')
				imgui.Text(u8'* ���� �������� ������� ��� ����� ���')
				imgui.Text(u8'* ���� �������� � ������� ����� ���� ��� ������������ ���� � �������')
				imgui.Text(ti.ICON_SWORD)
				imgui.PopFont()
			elseif nav.sel[0] == 2 then
				imgui.Checkbox(u8'�������� ����������� ����������� ����������', keyboardMove)
				imgui.Checkbox(u8'�������� ����������� ����������', keyboard)
				imgui.Combo(u8'��� ����������', keyboard_type, keyboardList.var, #keyboardList.arr)
				if imgui.SliderFloat(u8'������ ����������', kSize, 0.5, 2.0) then 
					kFontChanged = true
				end
				if imgui.Button(u8'�������� ������', imgui.ImVec2(-1, 0)) then kSize[0], kFontChanged = 1.0, true end
			elseif nav.sel[0] == 3 then
				imgui.Checkbox(u8'�������� ����������� ����������� ����', mouseMove)
				imgui.Checkbox(u8'�������� ����', mouse)
				if imgui.SliderFloat(u8'������ ����', mSize, 0.5, 2.0) then mFontChanged = true end
				if imgui.Button(u8'�������� ������', imgui.ImVec2(-1, 0)) then mSize[0], mFontChanged = 1.0, true end
			elseif nav.sel[0] == 4 then
				if imgui.Combo(u8'����', theme, themesList.var, #themesList.arr) then
					keyColors = setKeyColors()
					if not mLoad and theme[0] == 7 then
						theme[0] = 6
						print('��� ����������������� ���� "MoonMonet", ���������� - https://www.blast.hk/threads/105945/')
						printChat('{FF0000}������, � ��� �� ����������� ���������� "MoonMonet", ���� ���� �������� �� "����"')
						printChat('��� ����������������� ���� "MoonMonet", ���������� - https://www.blast.hk/threads/105945/')
						printChat('������ ����������� � ����� ������')
						setClipboardText('https://www.blast.hk/threads/105945/')
					end
					styles[theme[0] ]()
				end
				if imgui.Checkbox(u8'���������� ������', rounding) then defaultStyle() end
				imgui.Text(u8'������������� ����')
				if imgui.ColorEdit4(u8'���� ������', cStyleEdit['mainColor'], imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.AlphaPreviewHalf) then 
					keyColors = setKeyColors()
				end
				if imgui.ColorEdit4(u8'���� �������', cStyleEdit['activeColor'], imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.AlphaPreviewHalf) then 
					keyColors = setKeyColors()
				end
				if imgui.ColorEdit4(u8'���� �������', cStyleEdit['borderColor'], imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.AlphaPreviewHalf) then 
					keyColors = setKeyColors()
				end
				if imgui.ColorEdit4(u8'����  ������', cStyleEdit['textColor'], imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.AlphaPreviewHalf) then 
					keyColors = setKeyColors()
				end
				imgui.Text(u8'���� MoonMonet')
				if not mLoad then
					imgui.TextDisabled(u8'!!! � ��� �� ����������� ���������� MoonMonet.\n������� ��� ��������� ������ !!!')
					if imgui.IsItemHovered() and imgui.IsItemClicked() then 
						print('��� ����������������� ���� "MoonMonet", ���������� - https://www.blast.hk/threads/105945/')
						printChat('��� ����������������� ���� "MoonMonet", ���������� - https://www.blast.hk/threads/105945/')
						printChat('������ ����������� � ����� ������')
						setClipboardText('https://www.blast.hk/threads/105945/')
					end
				end
				if imgui.ColorEdit4(u8'�������� ����', monetColorEdit, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.AlphaPreviewHalf) then 
					monetColor = imgui.ImVec4(monetColorEdit[0],monetColorEdit[1],monetColorEdit[2],monetColorEdit[3])
					styles[theme[0] ]()
				end
				if imgui.SliderFloat(u8'������� ������', monetBrightness, 0.5, 2.0) then styles[theme[0] ]() end
				imgui.Checkbox(u8'�������������� ������� �������', rainbowMode.active)
				imgui.Checkbox(u8'������ �����', rainbowMode.async)
				imgui.SliderFloat(u8'�������� �����������', rainbowMode.speed, 0.0, 20.0)
			elseif nav.sel[0] == 5 then
				local w = imgui.GetWindowWidth()
				imgui.Text(u8'� ���� ������� ����� ��������� ����������� "�����" ����������')
				imgui.Text(u8'��� ���������/�������� ��������, ������� �� ��� ���')
				if imgui.Button(u8'�������� ����', imgui.ImVec2((w-25)/3, 0))  then
					table.insert(keyboards[#keyboards].keyboard.blocks, {})
				end
				imgui.SameLine()
				if imgui.Button(u8'�������� �����', imgui.ImVec2((w-25)/3, 0)) then
					addLine = true
					printChat('�������� ����, � ������� ����� �������� �����')
				end
				imgui.SameLine()
				if imgui.Button(u8'�������� �������', imgui.ImVec2((w-25)/3, 0)) then 
					addKey.state[0] = true 
					printChat('�������� �����, �� ������� ����� �������� �������')
				end
    			imgui.Spacing()
				imgui.BeginTitleChild(u8'�������� ����������', imgui.ImVec2(-1, imgui.GetWindowHeight()-105))
				local spacing = imgui.GetStyle().ItemSpacing
				local blocks = keyboards[#keyboards].keyboard.blocks
				for ib, block in ipairs(blocks) do
					local maxSize = getBlockMaxSize(block)
					imgui.BeginTitleChild(u8'���� #'..ib, imgui.ImVec2(maxSize.x+20, -1), imgui.GetStyle().Colors[imgui.Col.Button])
					for il, line in ipairs(block) do
						local maxHeight = getLineMaxHeight(line)
						imgui.BeginTitleChild2(u8'����� #'..il, imgui.ImVec2(-1, maxHeight), imgui.GetStyle().Colors[imgui.Col.ButtonActive], 8)
						local y = imgui.GetCursorPosY()
						if #line == 0 then imgui.NewLine() else
							for i, key in ipairs(line) do
								if key.pos then
									local x = imgui.GetCursorPosX()
									imgui.SetCursorPosX((x+20*(kSize[0])*(key.pos-1))+spacing.x*key.pos-1)
								end
								if isKeyDown(key.id) then key.time = os.clock() + 0.015 end
								renderKey(key)
								if imgui.IsItemHovered() then
									if addKey.state[0] and (imgui.IsItemClicked() or imgui.IsItemClicked(1)) then
										imgui.OpenPopup(u8'�������� �������') 
										addKey.block, addKey.line = ib, il
									elseif imgui.IsItemClicked(1) and not editElement.state[0] then 
										imgui.OpenPopup(u8'�������� �������')
										editElement.state[0] = true
										editElement.block = ib
										editElement.line = il
										editElement.key = i
										editElement.keySize = key.size and {x = new.int(key.size.x), y = new.int(key.size.y)} or {x = new.int(20), y = new.int(20)}
										editElement.tKey = key
									end
								end
								if i ~= #line then
									imgui.SameLine()
								end
							end
						end
						editKeyPopups()
						imgui.EndChild()
						if imgui.IsItemHovered() then
							if addKey.state[0] and (imgui.IsItemClicked() or imgui.IsItemClicked(1)) then
								imgui.OpenPopup(u8'�������� �������') 
								addKey.block, addKey.line = ib, il
							elseif not editElement.state[0] and imgui.IsItemClicked(1) then
								imgui.OpenPopup(u8'�������� �������')
								editElement.state[0] = true
								editElement.block = ib
								editElement.line = il
								editElement.key = 0
							end
						end
					end
					editKeyPopups()
					imgui.EndChild()
					if imgui.IsItemHovered() then
						if addLine and (imgui.IsItemClicked() or imgui.IsItemClicked(1)) then
							table.insert(keyboards[#keyboards].keyboard.blocks[ib], {})
							addLine = false
						elseif not editElement.state[0] and imgui.IsItemClicked(1) then
							imgui.OpenPopup(u8'�������� �������')
							editElement.state[0] = true
							editElement.block = ib
							editElement.line = 0
							editElement.key = 0
						end
					end
					imgui.SameLine()
				end
				editKeyPopups()

				imgui.EndChild()
			end
			if nav.sel[0] ~= 5 then
				imgui.PushFont(fonts[16])
					imgui.SetCursorPosY(imgui.GetWindowHeight()-125)
					imgui.Link('qiwi.com/n/CAJLAT', ti.ICON_LINK..u8' ���� �� �������� �� BlastHack')
					imgui.Text(ti.ICON_INFO_CIRCLE..u8' ���� ������� �� �����.') 
					imgui.Text(ti.ICON_MESSAGE_CIRCLE_2..u8' ����� � �������:') imgui.SameLine()
					imgui.Link('https://vk.me/cajlat', ti.ICON_BRAND_VK) imgui.SameLine()
					imgui.Link('https://t.me/cajlat', ti.ICON_BRAND_TELEGRAM) imgui.SameLine()
					imgui.Link('https://github.com/thecajlat', ti.ICON_BRAND_GITHUB)
					imgui.Text(ti.ICON_BUSINESSPLAN..u8' ���������� ������:') imgui.SameLine()
					imgui.Link('https://qiwi.com/n/CAJLAT', 'Qiwi') imgui.SameLine()
					imgui.Link('https://www.donationalerts.com/r/i_cajlat', 'DonationAlerts')
					imgui.Text(ti.ICON_HEART..u8' ���� �������, ���� ����� '..ti.ICON_HEART)
				imgui.PopFont()
			end
			imgui.SetCursorPos(imgui.ImVec2(10, imgui.GetWindowHeight()-30))
			if imgui.Button(u8'��������� ���������', imgui.ImVec2(-1, 0)) then 
				iniSave()
				printChat('��������� ������� ���������')
			end
			imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth()-28, y))
			if imgui.CloseButton(20, 2) then settings[0] = false end
		imgui.EndChild()
	imgui.End()
end)

-- ����
imgui.OnFrame(function() return mouse[0] and not isGamePaused() and gta and #keyboards > 0 end, function(player)
	player.HideCursor = not settings[0]

	imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(5.0, 2.4)) -- ���� ��������� ������
	imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0,0,0,0)) -- ������� ���
	imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0.0) -- ������� ������� ����
	imgui.SetNextWindowPos(mPos, imgui.Cond.FirstUseEver, imgui.ImVec2(0, 0))
	imgui.Begin('##mouse', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + (mouseMove[0] and 0 or imgui.WindowFlags.NoMove) )
		mPos = imgui.GetWindowPos()
		imgui.SetWindowFontScale(mSize[0])
		local spacing = imgui.GetStyle().ItemSpacing
		local y = imgui.GetCursorPosY()
		for il, line in ipairs(mouse_keys) do
			if il == 2 then imgui.SetCursorPosY(y+50*mSize[0]+spacing.y*2) end
			imgui.BeginGroup()
			for i, key in ipairs(line) do
				if key.name == 'MMB' then renderWheel()
					imgui.SetCursorPosY(18*mSize[0])
				elseif key.name == 'RMB' then
					imgui.SetCursorPosY(2.2)
				end
				if isKeyDown(key.id) then key.time = os.clock() + 0.015 end
				renderKey(key, true)
				if i ~= #line then imgui.SameLine() end
			end
			imgui.EndGroup()
		end
	imgui.End()
	imgui.PopStyleColor()
	imgui.PopStyleVar(2)
end)


function editKeyPopups()
	if imgui.BeginPopupModal(u8'�������� �������', addKey.state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.Text(string.format(u8'�������� ������� � ���� #%s, �� ����� #%s', addKey.block, addKey.line))
		imgui.PushItemWidth(90)
		imgui.Combo(u8'�������� �������', addKey.selected, keysList.var, #keysList.arr)
		imgui.PopItemWidth()
		if imgui.Button(u8'��������', imgui.ImVec2(-1, 30)) then
			table.insert(keyboards[#keyboards].keyboard.blocks[addKey.block][addKey.line], keys[addKey.selected[0]+1])
		end
		imgui.EndPopup()
	end
	if imgui.BeginPopupModal(u8'�������� �������', editElement.state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
		if editElement.key ~= 0 then
			local key = keyboards[#keyboards].keyboard.blocks[editElement.block][editElement.line][editElement.key]
			imgui.Text(string.format(u8'��������� ������� #%s � ����� #%s �� ����� #%s', editElement.key, editElement.block, editElement.line))
			imgui.SliderInt(u8'������', editElement.keySize.x, 15, 180)
			imgui.SliderInt(u8'������', editElement.keySize.y, 15, 80)
			imgui.PushItemWidth(90)
			imgui.Combo(u8'�������� �������', editElement.selected, keysList.var, #keysList.arr)
			imgui.Text(u8'������� �������:')
			renderKey(key)
			imgui.Text(u8'����� �������:')
			renderKey({name = keys[editElement.selected[0]+1].name, size = {x = editElement.keySize.x[0], y = editElement.keySize.y[0]}})
			imgui.PopItemWidth()
			if imgui.Button(u8'��������� ��������� �������', imgui.ImVec2(-1, 30)) then
				keyboards[#keyboards].keyboard.blocks[editElement.block][editElement.line][editElement.key] = keys[editElement.selected[0]+1]
			end
			if imgui.Button(u8'��������� ��������� �������', imgui.ImVec2(-1, 30)) then
				key.size = {x = editElement.keySize.x[0], y = editElement.keySize.y[0]}
			end
			if imgui.Button(u8'�������', imgui.ImVec2(-1, 30)) then
				table.remove(keyboards[#keyboards].keyboard.blocks[editElement.block][editElement.line], editElement.key)
				editElement.state[0] = false
				imgui.CloseCurrentPopup()
			end
		elseif editElement.line ~= 0 then
			imgui.Text(string.format(u8'�� ������������� ������ ������� ����� #%s � ����� #%s?', editElement.line, editElement.block))
			if imgui.Button(u8'������', imgui.ImVec2(-1, 30)) then
				editElement.state[0] = false
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'�������', imgui.ImVec2(-1, 30)) then
				table.remove(keyboards[#keyboards].keyboard.blocks[editElement.block], editElement.line)
				editElement.state[0] = false
				imgui.CloseCurrentPopup()
			end
		else
			imgui.Text(string.format(u8'�� ������������� ������ ������� ���� #%s', editElement.block))
			if imgui.Button(u8'������', imgui.ImVec2(-1, 30)) then
				editElement.state[0] = false
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'�������', imgui.ImVec2(-1, 30)) then
				table.remove(keyboards[#keyboards].keyboard.blocks, editElement.block)
				editElement.state[0] = false
				imgui.CloseCurrentPopup()
			end
		end
		imgui.EndPopup()
	end
end

function imgui.DrawMenu(menu)
	imgui.BeginGroup()
	imgui.PushFont(fonts[60])
	imgui.SetCursorPosX(24)
	imgui.TextDisabled(ti.ICON_KEYBOARD..ti.ICON_MOUSE)
	imgui.PopFont()
	imgui.SetCursorPos(imgui.ImVec2(1, 70))
		imgui.PushFont(fonts[16])
		for i, v in ipairs(nav.list) do
			if imgui.CustomMenuItem(i, v, imgui.ImVec2(140, 40)) then nav.sel[0] = i end
		end
		imgui.PopFont()
		imgui.SetCursorPos(imgui.ImVec2(75-imgui.CalcTextSize('Keyboard & Mouse v.' .. thisScript().version).x/2, imgui.GetWindowHeight()-40))
		imgui.Text('Keyboard & Mouse v.' .. thisScript().version)
		imgui.SetCursorPosX(75-imgui.CalcTextSize('by CaJlaT').x/2)
		imgui.TextDisabled('by CaJlaT')
	imgui.EndGroup()
end


function imgui.CustomMenuItem(index, item, size)
	local bool = false
	local DL = imgui.GetWindowDrawList()
	local p = imgui.GetCursorScreenPos()
	local w = imgui.GetWindowPos()
	local ts = imgui.CalcTextSize(item.icon..' '..item.name)
	if imgui.InvisibleButton(item.name..'##'..index, size) then bool = true end
	if nav.sel[0] == index then
		local colors = {
			imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.Button]),
			imgui.GetColorU32Vec4(imgui.ImVec4(0,0,0,0))
		}
		DL:AddRectFilledMultiColor(imgui.ImVec2(w.x+1, p.y), imgui.ImVec2(p.x+size.x, p.y+size.y), colors[1], colors[2], colors[2], colors[1]);
	end
	DL:AddText(imgui.ImVec2(w.x+10, p.y + (size.y-ts.y)/2), -1, item.icon..' '..item.name)
	return bool
end

function imgui.CloseButton(size, thickness)
	local bool = false
	local DL = imgui.GetWindowDrawList()
	local p = imgui.GetCursorScreenPos()
	if imgui.InvisibleButton('##close', imgui.ImVec2(size, size)) then bool = true end
	local cColor = imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.Button])
	if imgui.IsItemHovered() then
		cColor = imgui.IsItemClicked() and imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.ButtonActive]) or imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
		DL:AddLine(imgui.ImVec2(p.x+size/3.5, p.y+size/3.5), imgui.ImVec2(p.x+size/1.5, p.y+size/1.5), cColor, thickness)
		DL:AddLine(imgui.ImVec2(p.x+size/3.5, p.y+size/1.5), imgui.ImVec2(p.x+size/1.5, p.y+size/3.5), cColor, thickness)
	end
	DL:AddCircle(imgui.ImVec2(p.x+size/2,p.y+size/2),size/2, cColor, 20, thickness)
	return bool
end

-- by Gorskin
function imgui.BeginTitleChild(str_id, size, colorBegin, colorText, colorLine, offset)
    colorBegin = colorBegin or imgui.GetStyle().Colors[imgui.Col.Button]
    colorText = colorText or imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    colorLine = colorLine or imgui.GetStyle().Colors[imgui.Col.Button]
    local DL = imgui.GetWindowDrawList()
    local posS = imgui.GetCursorScreenPos()
    local rounding = imgui.GetStyle().ChildRounding
    local title = str_id:gsub('##.+$', '')
    local sizeT = imgui.CalcTextSize(title)
    local bgColor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.WindowBg])
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.BeginChild(str_id, size, true)
    imgui.SetCursorPos(imgui.ImVec2(0, 30))
    imgui.Spacing()
    imgui.PopStyleColor(1)
    size.x = size.x == -1.0 and imgui.GetWindowWidth() or size.x
    size.y = size.y == -1.0 and imgui.GetWindowHeight() or size.y
    offset = offset or (size.x-sizeT.x)/2
    DL:AddRect(posS, imgui.ImVec2(posS.x + size.x, posS.y + size.y), imgui.ColorConvertFloat4ToU32(colorLine), rounding, _, 1)
    DL:AddRectFilled(imgui.ImVec2(posS.x, posS.y), imgui.ImVec2(posS.x + size.x, posS.y + 25), imgui.ColorConvertFloat4ToU32(colorBegin), rounding, 1 + 2)
    DL:AddText(imgui.ImVec2(posS.x + offset, posS.y + 12 - (sizeT.y / 2)), imgui.ColorConvertFloat4ToU32(colorText), title)
end

--by Cosmo
function imgui.BeginTitleChild2(str_id, size, color, offset)
    color = color or imgui.GetStyle().Colors[imgui.Col.Border]
    offset = offset or 30
    local DL = imgui.GetWindowDrawList()
    local posS = imgui.GetCursorScreenPos()
    local rounding = imgui.GetStyle().ChildRounding
    local title = str_id:gsub('##.+$', '')
    local sizeT = imgui.CalcTextSize(title)
    local padd = imgui.GetStyle().WindowPadding
    local bgColor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.WindowBg])
    imgui.Spacing()

    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.BeginChild(str_id, size, true)
    imgui.Spacing()
    imgui.PopStyleColor(2)

    size.x = size.x == -1.0 and imgui.GetWindowWidth() or size.x
    size.y = size.y == -1.0 and imgui.GetWindowHeight() or size.y
    DL:AddRect(posS, imgui.ImVec2(posS.x + size.x, posS.y + size.y), imgui.ColorConvertFloat4ToU32(color), rounding, _, 1)
    DL:AddLine(imgui.ImVec2(posS.x + offset - 3, posS.y), imgui.ImVec2(posS.x + offset + sizeT.x + 3, posS.y), bgColor, 3)
    DL:AddText(imgui.ImVec2(posS.x + offset, posS.y - (sizeT.y / 2)), imgui.ColorConvertFloat4ToU32(color), title)
end

-- by neverlane (Cosmo)
function imgui.Link(link,name,myfunc)
    myfunc = type(name) == 'boolean' and name or myfunc or false
    name = type(name) == 'string' and name or type(name) == 'boolean' and link or link
    local size = imgui.CalcTextSize(name)
    local p = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local resultBtn = imgui.InvisibleButton('##'..link..name, size)
    if resultBtn then
        if not myfunc then
            os.execute('start '..link)
        end
    end
    imgui.SetCursorPos(p2)
    if imgui.IsItemHovered() then
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonHovered], name)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
    else
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.Button], name)
    end
    return resultBtn
end

function getBlockMaxSize(block)
	local max_size = {x = 20, y = 20}
	local spacing = imgui.GetStyle().ItemSpacing
	for i, line in ipairs(block) do
		local size = {x = 0, y = 0}
		for i, key in ipairs(line) do
			size.x = size.x + (key.size and key.size.x or 20) + spacing.x
			size.y = (key.size and key.size.y or 20) + spacing.y
		end
		if size.x > max_size.x then max_size.x = size.x end
		if size.y > max_size.y then max_size.y = size.y end
	end
	max_size.x, max_size.y = max_size.x + 20, max_size.y + 20
	return max_size
end
function getLineMaxHeight(line)
	local max = 20
	local spacing = imgui.GetStyle().ItemSpacing
	local size = 0
	for i, key in ipairs(line) do
		size = (key.size and key.size.y or 20) + spacing.y
		if size > max then max = size end
	end
	return max + 20
end

function renderKey(key, isMouse)
	local resize = isMouse and mSize[0] or kSize[0]
	if not key.time then key.time = 0 end
	local DL = imgui.GetWindowDrawList()
	local cp = imgui.GetCursorScreenPos()
	local spacing = imgui.GetStyle().ItemSpacing
	local size = (key.size 
		and imgui.ImVec2((key.size.x > 20 and key.size.x * resize + spacing.x or key.size.x * resize), (key.size.y > 20 and key.size.y * resize + spacing.y or key.size.y * resize))
		or imgui.ImVec2(20 * resize, 20 * resize))
	local text = key.name:gsub('#.+', '')
	local ts = imgui.CalcTextSize(text)
	local a, b = cp, imgui.ImVec2(cp.x+size.x, cp.y+size.y)
	local tPos = imgui.ImVec2(a.x+(size.x-ts.x)/2, a.y+(size.y-ts.y)/2)
	local color = imgui.ColorConvertFloat4ToU32((key.time >= os.clock() and (rainbowMode.active[0] and rainbow(rainbowMode.speed[0], 0.4, key.id) or keyColors.active) or keyColors.main))
	imgui.Dummy(size)
	DL:AddRectFilled(a, b, color, rounding[0] and 6 or 0)
	DL:AddRect(a, b, imgui.ColorConvertFloat4ToU32((theme[0] == 6 and cStyle['borderColor'] or imgui.GetStyle().Colors[imgui.Col.FrameBg])), rounding[0] and 6 or 0, _, 1.2)
	DL:AddText(tPos, (theme[0] == 6 and imgui.GetColorU32Vec4(cStyle['textColor']) or -1), text)
end

function renderWheel()
	local resize = mSize[0]
	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()
	local spacing = imgui.GetStyle().ItemSpacing
	local color1 = imgui.ColorConvertFloat4ToU32((wheel[1] and (wheel[1][1] > 0 and (rainbowMode.active[0] and rainbow(rainbowMode.speed[0], 0.4, 10) or keyColors.active) or keyColors.main) or keyColors.main))
	local color2 = imgui.ColorConvertFloat4ToU32((wheel[1] and (wheel[1][1] < 0 and (rainbowMode.active[0] and rainbow(rainbowMode.speed[0], 0.4, 20) or keyColors.active) or keyColors.main) or keyColors.main))
	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y+1), imgui.ImVec2(p.x+32*resize+spacing.x, p.y+16*resize), color1, rounding[0] and 6 or 0)
	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y+35*resize), imgui.ImVec2(p.x+32*resize+spacing.x, p.y+52*resize), color2, rounding[0] and 6 or 0)
	if #wheel > 0 and wheel[1][1] ~= 0 then
		if wheel[1][2] < os.clock() then
			table.remove(wheel, 1)
		end
	end
	local a, b = p, imgui.ImVec2(p.x+32*resize+spacing.x, p.y+53*resize)
	draw_list:AddRect(a, b, imgui.ColorConvertFloat4ToU32((theme[0] == 6 and cStyle['borderColor'] or imgui.GetStyle().Colors[imgui.Col.FrameBg])), rounding[0] and 6 or 0, _, 1.2)
end

function setKeyColors()
	for k, v in pairs(cStyleEdit) do
		cStyle[k] = imgui.ImVec4(v[0], v[1], v[2], v[3])
	end
	return {
		active = (theme[0] == 6 and 
			imgui.ImVec4(cStyleEdit['activeColor'][0], cStyleEdit['activeColor'][1], cStyleEdit['activeColor'][2], cStyleEdit['activeColor'][3])
			or imgui.GetStyle().Colors[imgui.Col.ButtonActive]),
		main = (theme[0] == 6 and 
			imgui.ImVec4(cStyleEdit['mainColor'][0], cStyleEdit['mainColor'][1], cStyleEdit['mainColor'][2], cStyleEdit['mainColor'][3])
			or imgui.GetStyle().Colors[imgui.Col.ChildBg])
	}
end

-- ���� �������� � ����� ������� ���� ��� ������������
addEventHandler("onWindowMessage", function (msg, wparam, lparam)
    if msg == 6 then
        if wparam == 0 then
            gta = false
        elseif wparam == 1 then
            gta = true
        end
    end
end)

function iniSave()
	ini.config.active = keyboard[0]
	ini.mouse.active = mouse[0]
	ini.config.mode = keyboard_type[0]
	ini.config.move = keyboardMove[0]
	ini.mouse.move = mouseMove[0]
	ini.config.theme = theme[0]
	ini.config.rounding = rounding[0]
	ini.config.size = kSize[0]
	ini.mouse.size = mSize[0]
	ini.pos.x, ini.pos.y = kPos.x, kPos.y
	ini.mouse.x, ini.mouse.y = mPos.x, mPos.y
	for k, v in pairs(ini.cStyle) do
		ini.cStyle[k] =  rgba_to_argb(imgui.ColorConvertFloat4ToU32(cStyle[k]))
	end
	ini.monet.mainColor = rgba_to_argb(imgui.ColorConvertFloat4ToU32(monetColor))
	ini.monet.brightness = monetBrightness[0]
	ini.rainbowMode.active = rainbowMode.active[0]
	ini.rainbowMode.speed = rainbowMode.speed[0]
	ini.rainbowMode.async = rainbowMode.async[0]
	for ik, keyboard in ipairs(keyboards) do
		for ib, block in ipairs(keyboard.keyboard.blocks) do
			for il, line in ipairs(block) do
				for i, key in ipairs(line) do
					key.time = -1
				end
			end
		end
	end
	inicfg.save(ini, iniFile)
	json(keyboardsDir):write(keyboards)
end

function explode_argb(argb)
	local a = bit.band(bit.rshift(argb, 24), 0xFF)
	local r = bit.band(bit.rshift(argb, 16), 0xFF)
	local g = bit.band(bit.rshift(argb, 8), 0xFF)
	local b = bit.band(argb, 0xFF)
	return a, r, g, b
end
function join_argb(a, r, g, b)
	local argb = b  -- b
	argb = bit.bor(argb, bit.lshift(g, 8))  -- g
	argb = bit.bor(argb, bit.lshift(r, 16)) -- r
	argb = bit.bor(argb, bit.lshift(a, 24)) -- a
	return argb
end
function argb_to_rgba(argb)
	local a, r, g, b = explode_argb(argb)
	return join_argb(r, g, b, a)
end

function rgba_to_argb(rgba)
	local a, b, g, r = explode_argb(rgba)
	return join_argb(a, r, g, b)
end

function onScriptTerminate(s) if s == thisScript() then iniSave() end end

function rainbow(speed, alpha, modify)
	alpha = alpha or 1
    modify = modify or 0
    local time = os.clock()
    if rainbowMode.async[0] then time = os.clock() + modify end
    return imgui.ImVec4(math.floor(math.sin(time * speed) * 127 + 128)/255, math.floor(math.sin(time * speed + 2) * 127 + 128)/255, math.floor(math.sin(time * speed + 4) * 127 + 128)/255, alpha)
end

function getKeyboardsList()
	if not doesFileExist(keyboardsDir) then
		printChat('������, �� ������ ���� �� ������� ���������. ���������� �������������� ��������...')
		download = downloadUrlToFile(kayboardsUrl, keyboardsDir, function(id, status, p1, p2) if status ~= 58 then return end download = nil end)
		while download do wait(100) end
		keyboards = json(keyboardsDir):read()
		printChat('�������� ���������. �������� ���� :)')
	else
		keyboards = json(keyboardsDir):read()
		if not keyboards or #keyboards == 0 then
			keyboards = {}
			printChat('������, ���� � ������������ �� ��������. ���������� �������������� ��������...')
			download = downloadUrlToFile(kayboardsUrl, keyboardsDir, function(id, status, p1, p2) if status ~= 58 then return end download = nil end)
			while download do wait(100) end
			keyboards = json(keyboardsDir):read()
			printChat('�������� ���������. �������� ���� :)')
		end
	end
	for i, v in ipairs(keyboards) do table.insert(keyboardList.arr, u8(v.name)) end
	for i, v in ipairs(keys) do table.insert(keysList.arr, u8(v.name)) end
	keyboardList.var = new['const char*'][#keyboardList.arr](keyboardList.arr)
	keysList.var = new['const char*'][#keysList.arr](keysList.arr)
	return true
end

keys = {
	{name = 'Esc', id = 0x1B, size = {x = 22, y = 20}},
	{name = 'F1', id = 0x70, size = {x = 22, y = 20}},
	{name = 'F2', id = 0x71, size = {x = 22, y = 20}},
	{name = 'F3', id = 0x72, size = {x = 22, y = 20}},
	{name = 'F4', id = 0x73, size = {x = 22, y = 20}},
	{name = 'F5', id = 0x74, size = {x = 22, y = 20}},
	{name = 'F6', id = 0x75, size = {x = 22, y = 20}},
	{name = 'F7', id = 0x76, size = {x = 22, y = 20}},
	{name = 'F8', id = 0x77, size = {x = 22, y = 20}},
	{name = 'F9', id = 0x78, size = {x = 22, y = 20}},
	{name = 'F10', id = 0x79, size = {x = 24, y = 20}},
	{name = '`', id = 0xC0},
	{name = '1', id = 0x31},
	{name = '2', id = 0x32},
	{name = '3', id = 0x33},
	{name = '4', id = 0x34},
	{name = '5', id = 0x35},
	{name = '6', id = 0x36},
	{name = '7', id = 0x37},
	{name = '8', id = 0x38},
	{name = '9', id = 0x39},
	{name = '0', id = 0x30},
	{name = '-', id = 0xBD},
	{name = '+', id = 0xBB},
	{name = '<-', id = 0x08, size = {x = 25, y = 20}},
	{name = 'Tab', id = 0x09, size = {x = 25, y = 20}},
	{name = 'Q', id = 0x51},
	{name = 'W', id = 0x57},
	{name = 'E', id = 0x45},
	{name = 'R', id = 0x52},
	{name = 'T', id = 0x54},
	{name = 'Y', id = 0x59},
	{name = 'U', id = 0x55},
	{name = 'I', id = 0x49},
	{name = 'O', id = 0x4F},
	{name = 'P', id = 0x50},
	{name = '[', id = 0xDB},
	{name = ']', id = 0xDD},
	{name = '\\', id = 0xDC},
	{name = 'Caps', id = 0x14, size = {x = 30, y = 20}},
	{name = 'A', id = 0x41},
	{name = 'S', id = 0x53},
	{name = 'D', id = 0x44},
	{name = 'F', id = 0x46},
	{name = 'G', id = 0x47},
	{name = 'H', id = 0x48},
	{name = 'J', id = 0x4A},
	{name = 'K', id = 0x4B},
	{name = 'L', id = 0x4C},
	{name = ';', id = 0xBA},
	{name = '\"', id = 0xDE},
	{name = 'Enter', id = 0x0D, size = {x = 35, y = 20}},
	{name = 'Shift#Left', id = 0xA0, size = {x = 42, y = 20}},
	{name = 'Z', id = 0x5A},
	{name = 'X', id = 0x58},
	{name = 'C', id = 0x43},
	{name = 'V', id = 0x56},
	{name = 'B', id = 0x42},
	{name = 'N', id = 0x4E},
	{name = 'M', id = 0x4D},
	{name = ',', id = 0xBC},
	{name = '.', id = 0xBE},
	{name = '/', id = 0xBF},
	{name = 'Shift#Right', id = 0xA1, size = {x = 45, y = 20}},
	{name = 'Ctrl#Left', id = 0xA2, size = {x = 30, y = 20}},
	{name = 'Win#Left', id = 0x5B, size = {x = 25, y = 20}},
	{name = 'Alt#Left', id = 0xA4, size = {x = 25, y = 20}},
	{name = ' #Space', id = 0x20, size = {x = 127, y = 20}},
	{name = 'Alt#Right', id = 0xA5, size = {x = 25, y = 20}},
	{name = 'Win#Right', id = 0x5C, size = {x = 25, y = 20}},
	{name = 'Ctrl#Right', id = 0xA3, size = {x = 30, y = 20}},
	{name = 'F11', id = 0x7A, size = {x = 24, y = 20}},
	{name = 'F12', id = 0x7B, size = {x = 24, y = 20}},
	{name = 'Ins', id = 0x2D, size = {x = 25, y = 20}},
	{name = 'HM', id = 0x24, size = {x = 25, y = 20}},
	{name = 'PU', id = 0x21, size = {x = 25, y = 20}},
	{name = 'Del', id = 0x2E, size = {x = 25, y = 20}},
	{name = 'End', id = 0x23, size = {x = 25, y = 20}},
	{name = 'PD', id = 0x22, size = {x = 25, y = 20}},
	{name = '/\\', id = 0x26},
	{name = '<', id = 0x25},
	{name = '\\/', id = 0x28},
	{name = '>', id = 0x27},
	{name = 'PS', id = 0x2C},
	{name = 'SL', id = 0x91},
	{name = 'P', id = 0x13},
	{name = "NL", id = 0x90, size = {x = 22, y = 20}},
	{name = "/#NumPad", id = 0x6F, size = {x = 18, y = 20}},
	{name = "*#NumPad", id = 0x6A, size = {x = 18, y = 20}},
	{name = "-#NumPad", id = 0x6D},
	{name = "7#NumPad", id = 0x67},
	{name = "8#NumPad", id = 0x68},
	{name = "9#NumPad", id = 0x69},
	{name = "+#NumPad", id = 0x6B, size = {x = 20, y =40}},
	{name = "4#NumPad", id = 0x64},
	{name = "5#NumPad", id = 0x65},
	{name = "6#NumPad", id = 0x66},
	{name = "1#NumPad", id = 0x61},
	{name = "2#NumPad", id = 0x62},
	{name = "3#NumPad", id = 0x63},
	{name = "E#NumPad", id = 0x0D, size = {x = 20, y = 40}},
	{name = "0#NumPad", id = 0x60, size = {x = 40, y = 20}},
	{name = ".#NumPad", id = 0x6E},
}

mouse_keys = {
	{
		{name = 'LMB', id = 0x01, size = { x = 32, y = 50}},
		{name = 'MMB', id = 0x04, size = { x = 32, y = 20}},
		{name = 'RMB', id = 0x02, size = { x = 32, y = 50}},
	},
	{
		{name = 'FWD', id = 0x06, size = { x = 51, y = 20}},
		{name = 'BWD', id = 0x05, size = { x = 51, y = 20}},
	}
}
function defaultStyle()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	style.WindowRounding = 10
	style.ChildRounding = 10
	style.FrameRounding = 6.0
	style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
	style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
	style.FramePadding = imgui.ImVec2(4.0, 3.0)
	style.IndentSpacing = 21
	style.ScrollbarSize = 10.0
	style.ScrollbarRounding = 13
	style.GrabMinSize = 17.0
	style.GrabRounding = 16.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
end
styles = {
	[0] = function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		colors[clr.Text]				   = ImVec4(0.90, 0.90, 0.90, 1.00)
		colors[clr.TextDisabled]		   = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.WindowBg]			   = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildBg]		  = ImVec4(0.10, 0.10, 0.10, 0.40)
		colors[clr.PopupBg]				= ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.Border]				 = ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.BorderShadow]		   = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]				= ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.FrameBgHovered]		 = ImVec4(0.19, 0.19, 0.19, 0.71)
		colors[clr.FrameBgActive]		  = ImVec4(0.34, 0.34, 0.34, 0.79)
		colors[clr.TitleBg]				= ImVec4(0.00, 0.69, 0.33, 0.80)
		colors[clr.TitleBgActive]		  = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.TitleBgCollapsed]	   = ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.MenuBarBg]			  = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.ScrollbarBg]			= ImVec4(0.16, 0.16, 0.16, 1.00)
		colors[clr.ScrollbarGrab]		  = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ScrollbarGrabActive]	= ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.CheckMark]			  = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrab]			 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrabActive]	   = ImVec4(0.00, 0.77, 0.37, 1.00)
		colors[clr.Button]				 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ButtonHovered]		  = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ButtonActive]		   = ImVec4(0.00, 0.87, 0.42, 1.00)
		colors[clr.Header]				 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.HeaderHovered]		  = ImVec4(0.00, 0.76, 0.37, 0.57)
		colors[clr.HeaderActive]		   = ImVec4(0.00, 0.88, 0.42, 0.89)
		colors[clr.Separator]			  = ImVec4(1.00, 1.00, 1.00, 0.40)
		colors[clr.SeparatorHovered]	   = ImVec4(1.00, 1.00, 1.00, 0.60)
		colors[clr.SeparatorActive]		= ImVec4(1.00, 1.00, 1.00, 0.80)
		colors[clr.ResizeGrip]			 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ResizeGripHovered]	  = ImVec4(0.00, 0.76, 0.37, 1.00)
		colors[clr.ResizeGripActive]	   = ImVec4(0.00, 0.86, 0.41, 1.00)
		colors[clr.PlotLines]			  = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotLinesHovered]	   = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.PlotHistogram]		  = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.TextSelectedBg]		 = ImVec4(0.00, 0.69, 0.33, 0.72)
		colors[clr.ModalWindowDimBg]   = ImVec4(0.17, 0.17, 0.17, 0.48)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		colors[clr.Text]				   = ImVec4(0.95, 0.96, 0.98, 1.00)
		colors[clr.TextDisabled]		   = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.WindowBg]			   = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ChildBg]		  = ImVec4(0.12, 0.12, 0.12, 0.40)
		colors[clr.PopupBg]				= ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]				 = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.BorderShadow]		   = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.FrameBg]				= ImVec4(0.22, 0.22, 0.22, 1.00)
		colors[clr.FrameBgHovered]		 = ImVec4(0.18, 0.18, 0.18, 1.00)
		colors[clr.FrameBgActive]		  = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]				= ImVec4(0.14, 0.14, 0.14, 0.81)
		colors[clr.TitleBgActive]		  = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.TitleBgCollapsed]	   = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]			  = ImVec4(0.20, 0.20, 0.20, 1.00)
		colors[clr.ScrollbarBg]			= ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]		  = ImVec4(0.36, 0.36, 0.36, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]	= ImVec4(0.24, 0.24, 0.24, 1.00)
		colors[clr.CheckMark]			  = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrab]			 = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrabActive]	   = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.Button]				 = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.ButtonHovered]		  = ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.ButtonActive]		   = ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.Header]				 = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.HeaderHovered]		  = ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.HeaderActive]		   = ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.ResizeGrip]			 = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.ResizeGripHovered]	  = ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.PlotLines]			  = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]	   = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]		  = ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00)
		colors[clr.TextSelectedBg]		 = ImVec4(1.00, 0.32, 0.32, 1.00)
		colors[clr.ModalWindowDimBg]   = ImVec4(0.26, 0.26, 0.26, 0.60)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		colors[clr.FrameBg]				= ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.FrameBgHovered]		 = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.FrameBgActive]		  = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.TitleBg]				= ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.TitleBgActive]		  = ImVec4(0.61, 0.16, 0.39, 1.00)
		colors[clr.TitleBgCollapsed]	   = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.CheckMark]			  = ImVec4(0.94, 0.30, 0.63, 1.00)
		colors[clr.SliderGrab]			 = ImVec4(0.85, 0.11, 0.49, 1.00)
		colors[clr.SliderGrabActive]	   = ImVec4(0.89, 0.24, 0.58, 1.00)
		colors[clr.Button]				 = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.ButtonHovered]		  = ImVec4(0.69, 0.17, 0.43, 1.00)
		colors[clr.ButtonActive]		   = ImVec4(0.59, 0.10, 0.35, 1.00)
		colors[clr.Header]				 = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.HeaderHovered]		  = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.HeaderActive]		   = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.Separator]			  = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.SeparatorHovered]	   = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.SeparatorActive]		= ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.ResizeGrip]			 = ImVec4(0.46, 0.11, 0.29, 0.70)
		colors[clr.ResizeGripHovered]	  = ImVec4(0.69, 0.16, 0.43, 0.67)
		colors[clr.ResizeGripActive]	   = ImVec4(0.70, 0.13, 0.42, 1.00)
		colors[clr.TextSelectedBg]		 = ImVec4(1.00, 0.78, 0.90, 0.35)
		colors[clr.Text]				   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]		   = ImVec4(0.60, 0.19, 0.40, 1.00)
		colors[clr.WindowBg]			   = ImVec4(0.06, 0.06, 0.06, 0.94)
		colors[clr.ChildBg]		  = ImVec4(0.00, 0.00, 0.00, 0.40)
		colors[clr.PopupBg]				= ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]				 = ImVec4(0.49, 0.14, 0.31, 1.00)
		colors[clr.BorderShadow]		   = ImVec4(0.49, 0.14, 0.31, 0.00)
		colors[clr.MenuBarBg]			  = ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.ScrollbarBg]			= ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]		  = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]	= ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.ModalWindowDimBg]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		colors[clr.WindowBg]			  = ImVec4(0.14, 0.12, 0.16, 1.00)
		colors[clr.ChildBg]		 = ImVec4(0.30, 0.20, 0.39, 0.40)
		colors[clr.PopupBg]			   = ImVec4(0.05, 0.05, 0.10, 0.90)
		colors[clr.Border]				= ImVec4(0.89, 0.85, 0.92, 0.30)
		colors[clr.BorderShadow]		  = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]			   = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.FrameBgHovered]		= ImVec4(0.41, 0.19, 0.63, 0.68)
		colors[clr.FrameBgActive]		 = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TitleBg]			   = ImVec4(0.41, 0.19, 0.63, 0.45)
		colors[clr.TitleBgCollapsed]	  = ImVec4(0.41, 0.19, 0.63, 0.35)
		colors[clr.TitleBgActive]		 = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.MenuBarBg]			 = ImVec4(0.30, 0.20, 0.39, 0.57)
		colors[clr.ScrollbarBg]		   = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.ScrollbarGrab]		 = ImVec4(0.41, 0.19, 0.63, 0.31)
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.CheckMark]			 = ImVec4(0.56, 0.61, 1.00, 1.00)
		colors[clr.SliderGrab]			= ImVec4(0.41, 0.19, 0.63, 0.24)
		colors[clr.SliderGrabActive]	  = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.Button]				= ImVec4(0.41, 0.19, 0.63, 0.44)
		colors[clr.ButtonHovered]		 = ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.ButtonActive]		  = ImVec4(0.64, 0.33, 0.94, 1.00)
		colors[clr.Header]				= ImVec4(0.41, 0.19, 0.63, 0.76)
		colors[clr.HeaderHovered]		 = ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.HeaderActive]		  = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ResizeGrip]			= ImVec4(0.41, 0.19, 0.63, 0.20)
		colors[clr.ResizeGripHovered]	 = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ResizeGripActive]	  = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotLines]			 = ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotLinesHovered]	  = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotHistogram]		 = ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TextSelectedBg]		= ImVec4(0.41, 0.19, 0.63, 0.43)
		colors[clr.TextDisabled]		  = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ModalWindowDimBg]  = ImVec4(0.20, 0.20, 0.20, 0.35)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		colors[clr.Text]				  = ImVec4(0.86, 0.93, 0.89, 0.78)
		colors[clr.TextDisabled]		  = ImVec4(0.71, 0.22, 0.27, 1.00)
		colors[clr.WindowBg]			  = ImVec4(0.13, 0.14, 0.17, 1.00)
		colors[clr.ChildBg]		 = ImVec4(0.20, 0.22, 0.27, 0.58)
		colors[clr.PopupBg]			   = ImVec4(0.20, 0.22, 0.27, 0.90)
		colors[clr.Border]				= ImVec4(0.31, 0.31, 1.00, 0.00)
		colors[clr.BorderShadow]		  = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]			   = ImVec4(0.20, 0.22, 0.27, 1.00)
		colors[clr.FrameBgHovered]		= ImVec4(0.46, 0.20, 0.30, 0.78)
		colors[clr.FrameBgActive]		 = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.TitleBg]			   = ImVec4(0.23, 0.20, 0.27, 1.00)
		colors[clr.TitleBgActive]		 = ImVec4(0.50, 0.08, 0.26, 1.00)
		colors[clr.TitleBgCollapsed]	  = ImVec4(0.20, 0.20, 0.27, 0.75)
		colors[clr.MenuBarBg]			 = ImVec4(0.20, 0.22, 0.27, 0.47)
		colors[clr.ScrollbarBg]		   = ImVec4(0.20, 0.22, 0.27, 1.00)
		colors[clr.ScrollbarGrab]		 = ImVec4(0.09, 0.15, 0.10, 1.00)
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.46, 0.20, 0.30, 0.78)
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.CheckMark]			 = ImVec4(0.71, 0.22, 0.27, 1.00)
		colors[clr.SliderGrab]			= ImVec4(0.47, 0.77, 0.83, 0.14)
		colors[clr.SliderGrabActive]	  = ImVec4(0.71, 0.22, 0.27, 1.00)
		colors[clr.Button]				= ImVec4(0.47, 0.77, 0.83, 0.14)
		colors[clr.ButtonHovered]		 = ImVec4(0.46, 0.20, 0.30, 0.86)
		colors[clr.ButtonActive]		  = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.Header]				= ImVec4(0.46, 0.20, 0.30, 0.76)
		colors[clr.HeaderHovered]		 = ImVec4(0.46, 0.20, 0.30, 0.86)
		colors[clr.HeaderActive]		  = ImVec4(0.50, 0.08, 0.26, 1.00)
		colors[clr.ResizeGrip]			= ImVec4(0.47, 0.77, 0.83, 0.04)
		colors[clr.ResizeGripHovered]	 = ImVec4(0.46, 0.20, 0.30, 0.78)
		colors[clr.ResizeGripActive]	  = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.PlotLines]			 = ImVec4(0.86, 0.93, 0.89, 0.63)
		colors[clr.PlotLinesHovered]	  = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.PlotHistogram]		 = ImVec4(0.86, 0.93, 0.89, 0.63)
		colors[clr.PlotHistogramHovered]  = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.TextSelectedBg]		= ImVec4(0.46, 0.20, 0.30, 0.43)
		colors[clr.ModalWindowDimBg]  = ImVec4(0.20, 0.22, 0.27, 0.73)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		colors[clr.Text]				 = ImVec4(0.92, 0.92, 0.92, 1.00)
		colors[clr.TextDisabled]		 = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.WindowBg]			 = ImVec4(0.06, 0.06, 0.06, 1.00)
		colors[clr.ChildBg]		= ImVec4(0.00, 0.00, 0.00, 0.40)
		colors[clr.PopupBg]			  = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]			   = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.BorderShadow]		 = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]			  = ImVec4(0.11, 0.11, 0.11, 1.00)
		colors[clr.FrameBgHovered]	   = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.FrameBgActive]		= ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.TitleBg]			  = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.TitleBgActive]		= ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.TitleBgCollapsed]	 = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]			= ImVec4(0.11, 0.11, 0.11, 1.00)
		colors[clr.ScrollbarBg]		  = ImVec4(0.06, 0.06, 0.06, 0.53)
		colors[clr.ScrollbarGrab]		= ImVec4(0.21, 0.21, 0.21, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.47, 0.47, 0.47, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.81, 0.83, 0.81, 1.00)
		colors[clr.CheckMark]			= ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.SliderGrab]		   = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.SliderGrabActive]	 = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.Button]			   = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.ButtonHovered]		= ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.ButtonActive]		 = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.Header]			   = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.HeaderHovered]		= ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.HeaderActive]		 = ImVec4(0.93, 0.65, 0.14, 1.00)
		colors[clr.Separator]			= ImVec4(0.21, 0.21, 0.21, 1.00)
		colors[clr.SeparatorHovered]	 = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.SeparatorActive]	  = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.ResizeGrip]		   = ImVec4(0.21, 0.21, 0.21, 1.00)
		colors[clr.ResizeGripHovered]	= ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.ResizeGripActive]	 = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.PlotLines]			= ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]	 = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]		= ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]	   = ImVec4(0.26, 0.59, 0.98, 0.35)
		colors[clr.ModalWindowDimBg] = ImVec4(0.80, 0.80, 0.80, 0.35)
	end,
	function ()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		colors[clr.Text]				   = ImVec4(0.90, 0.90, 0.90, 1.00)
		colors[clr.TextDisabled]		   = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.WindowBg]			   = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildBg]		  = ImVec4(0.10, 0.10, 0.10, 0.40)
		colors[clr.PopupBg]				= ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.Border]				 = ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.BorderShadow]		   = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]				= ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.FrameBgHovered]		 = ImVec4(0.19, 0.19, 0.19, 0.71)
		colors[clr.FrameBgActive]		  = ImVec4(0.34, 0.34, 0.34, 0.79)
		colors[clr.TitleBg]				= ImVec4(0.00, 0.69, 0.33, 0.80)
		colors[clr.TitleBgActive]		  = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.TitleBgCollapsed]	   = ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.MenuBarBg]			  = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.ScrollbarBg]			= ImVec4(0.16, 0.16, 0.16, 1.00)
		colors[clr.ScrollbarGrab]		  = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ScrollbarGrabActive]	= ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.CheckMark]			  = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrab]			 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrabActive]	   = ImVec4(0.00, 0.77, 0.37, 1.00)
		colors[clr.Button]				 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ButtonHovered]		  = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ButtonActive]		   = ImVec4(0.00, 0.87, 0.42, 1.00)
		colors[clr.Header]				 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.HeaderHovered]		  = ImVec4(0.00, 0.76, 0.37, 0.57)
		colors[clr.HeaderActive]		   = ImVec4(0.00, 0.88, 0.42, 0.89)
		colors[clr.Separator]			  = ImVec4(1.00, 1.00, 1.00, 0.40)
		colors[clr.SeparatorHovered]	   = ImVec4(1.00, 1.00, 1.00, 0.60)
		colors[clr.SeparatorActive]		= ImVec4(1.00, 1.00, 1.00, 0.80)
		colors[clr.ResizeGrip]			 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ResizeGripHovered]	  = ImVec4(0.00, 0.76, 0.37, 1.00)
		colors[clr.ResizeGripActive]	   = ImVec4(0.00, 0.86, 0.41, 1.00)
		colors[clr.PlotLines]			  = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotLinesHovered]	   = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.PlotHistogram]		  = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.TextSelectedBg]		 = ImVec4(0.00, 0.69, 0.33, 0.72)
		colors[clr.ModalWindowDimBg]   = ImVec4(0.17, 0.17, 0.17, 0.48)
	end,


	-- by THERION, edited by CaJlaT
	-- @param color number: Main color U32 representation.
	-- @param chroma_multiplier number: Color brightness. [0.5; 2.0].
	-- @param accurate_shades boolean: Use accurate shades.
	function()
		if monet then
			imgui.SwitchContext()
			local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col
			local function to_vec4(u32, a)
				local a_ = bit.band(bit.rshift(u32, 24), 0xFF) / 0xFF
				local r = bit.band(bit.rshift(u32, 16), 0xFF) / 0xFF
				local g = bit.band(bit.rshift(u32, 8), 0xFF) / 0xFF
				local b = bit.band(u32, 0xFF) / 0xFF
				a = a or a_
				return imgui.ImVec4(r, g, b, a)
		  	end

			local palette = monet.buildColors(rgba_to_argb(imgui.ColorConvertFloat4ToU32(monetColor)), monetBrightness[0], true)
		
			colors[clr.Text] = to_vec4(palette.neutral1.color_50)
			colors[clr.TextDisabled] = to_vec4(palette.accent1.color_800)

			colors[clr.WindowBg] = to_vec4(palette.neutral1.color_900, 0.94)
			colors[clr.ChildBg] = to_vec4(palette.neutral1.color_900, 0.40)
			colors[clr.PopupBg] = to_vec4(palette.neutral1.color_900, 0.94)

			colors[clr.Border] = to_vec4(palette.neutral1.color_100)
			colors[clr.BorderShadow] = to_vec4(palette.neutral2.color_900)

			colors[clr.FrameBg] = to_vec4(palette.accent1.color_800)
			colors[clr.FrameBgHovered] = to_vec4(palette.accent1.color_700)
			colors[clr.FrameBgActive] = to_vec4(palette.accent1.color_600)

			colors[clr.TitleBg] = to_vec4(palette.accent1.color_1000)
			colors[clr.TitleBgActive] = to_vec4(palette.accent1.color_800)
			colors[clr.TitleBgCollapsed] = to_vec4(palette.accent1.color_1000, 0.5)

			colors[clr.ScrollbarBg] = to_vec4(palette.accent1.color_800)
			colors[clr.ScrollbarGrab] = to_vec4(palette.accent1.color_500)
			colors[clr.ScrollbarGrabHovered] = to_vec4(palette.accent1.color_600)
			colors[clr.ScrollbarGrabActive] = to_vec4(palette.accent1.color_500)

			colors[clr.CheckMark] = to_vec4(palette.accent1.color_500)

			colors[clr.SliderGrab] = to_vec4(palette.accent1.color_500)
			colors[clr.SliderGrabActive] = to_vec4(palette.accent2.color_400)

			colors[clr.Button] = to_vec4(palette.accent1.color_800)
			colors[clr.ButtonHovered] = to_vec4(palette.accent1.color_700)
			colors[clr.ButtonActive] = to_vec4(palette.accent1.color_600)

			colors[clr.Header] = to_vec4(palette.accent1.color_800)
			colors[clr.HeaderHovered] = to_vec4(palette.accent1.color_700)
			colors[clr.HeaderActive] = to_vec4(palette.accent1.color_600)

			colors[clr.Separator] = to_vec4(palette.accent2.color_200)
			colors[clr.SeparatorHovered] = to_vec4(palette.accent2.color_100)
			colors[clr.SeparatorActive] = to_vec4(palette.accent2.color_50)

			colors[clr.ResizeGrip] = to_vec4(palette.accent2.color_900)
			colors[clr.ResizeGripHovered] = to_vec4(palette.accent2.color_800)
			colors[clr.ResizeGripActive] = to_vec4(palette.accent2.color_700)

			colors[clr.Tab] = to_vec4(palette.accent1.color_700)
			colors[clr.TabHovered] = to_vec4(palette.accent1.color_600)
			colors[clr.TabActive] = to_vec4(palette.accent1.color_500)

			colors[clr.PlotLines] = to_vec4(palette.accent3.color_300)
			colors[clr.PlotLinesHovered] = to_vec4(palette.accent3.color_50)
			colors[clr.PlotHistogram] = to_vec4(palette.accent3.color_300)
			colors[clr.PlotHistogramHovered] = to_vec4(palette.accent3.color_50)

			colors[clr.DragDropTarget] = to_vec4(palette.accent3.color_700)
		end
	end
}