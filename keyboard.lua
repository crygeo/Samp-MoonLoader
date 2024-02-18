script_author('CaJlaT')
script_name('KeyBoard')
script_version('2.1')
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local iniFile = 'keyboard.ini'
local ini = inicfg.load({
	config = {
		active = false,
		mode = 0,
		move = true,
		theme = 0
	},
	mouse = {
		active = false,
		x = 10,
		y = 200,
	},
	pos = {
		x = 10,
		y = 500
	}
}, iniFile)
if not doesFileExist('moonloader/config/'..iniFile) then inicfg.save(ini, iniFile) end

local settings = imgui.ImBool(false)
local keyboard = imgui.ImBool(ini.config.active)
local mouse = imgui.ImBool(ini.mouse.active)
local keyboard_type = imgui.ImInt(ini.config.mode)
local move = imgui.ImBool(ini.config.move)
local keyboard_pos = imgui.ImVec2(ini.pos.x, ini.pos.y)
local mouse_pos = imgui.ImVec2(ini.mouse.x, ini.mouse.y)
local theme = imgui.ImInt(ini.config.theme)

local wheel = {} -- ���� ����������� �������� ������

function main()
	sampRegisterChatCommand('keyboard', function() settings.v = not settings.v end)
	while true do
		wait(0)
		imgui.Process = settings.v or keyboard.v or mouse.v
		imgui.ShowCursor = settings.v
		delta = getMousewheelDelta()
		if delta ~= 0 then table.insert(wheel, {delta, os.clock()+0.05}) end 
	end
end

function imgui.OnDrawFrame()
	local X, Y = getScreenResolution()
	if settings.v then
		imgui.SetNextWindowSize(imgui.ImVec2(194, 120), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(X / 2, Y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("View keyboard presses", settings, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
		imgui.PushItemWidth(140)
		imgui.Combo("Tipo de teclado.", keyboard_type, {"Completo", "Sin NumPad", "Numer", "NumPad" , "Gaming"})
		imgui.PopItemWidth()
		imgui.Checkbox("Mostrar Teclado", keyboard)
		imgui.Checkbox("Mostrar Mouse", mouse)
		imgui.Checkbox("Permitir mover", move)
		imgui.PushItemWidth(140)
		if imgui.Combo("Tema", theme, {"Verder", "Rojo", "Magenta", "Morado", "Vino", "Amarillo"}) then styles[theme.v]() end
		imgui.PopItemWidth()
		imgui.SetCursorPosX((imgui.GetWindowWidth()-imgui.CalcTextSize('by CaJlaT').x)/2)
		imgui.TextDisabled('by CaJlaT')
		imgui.End()
	end
	if keyboard.v then
		imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(5.0, 2.4))
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0,0,0,0))
		imgui.SetNextWindowPos(keyboard_pos, imgui.Cond.FirstUseEver, imgui.ImVec2(0, 0))
		imgui.Begin('##keyboard', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + (move.v and 0 or imgui.WindowFlags.NoMove) )
			keyboard_pos = imgui.GetWindowPos()
			for i, line in ipairs(keyboards[keyboard_type.v+1]) do
				if (keyboard_type.v == 0 or keyboard_type.v == 1) and i == 4 then 
					imgui.SetCursorPosY(68) -- fix
				elseif (keyboard_type.v == 0 or keyboard_type.v == 1) and i == 6 then 
					imgui.SetCursorPosY(112) -- fix
				end
				for key, v in ipairs(line) do
					local size = imgui.CalcTextSize(v[1])
					if isKeyDown(v[2]) then
						print(v[2])
						imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.GetStyle().Colors[imgui.Col.ButtonActive])
					else
						imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0,0,0,0.4))
					end
					imgui.BeginChild('##'..i..key, imgui.ImVec2(size.x+11, (v[1] == '\n+' or v[1] == '\nE') and size.y + 14 or size.y + 5), true)
						imgui.Text(v[1])
					imgui.EndChild()
					imgui.PopStyleColor()
					if key ~= #line then
						imgui.SameLine()
						if v[3] then imgui.SameLine(imgui.GetCursorPosX()+v[3]) end
					end
				end
			end
		imgui.End()
		imgui.PopStyleColor()
		imgui.PopStyleVar()
	end
	if mouse.v then
		imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(5.0, 2.4)) 
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0,0,0,0)) 
		imgui.SetNextWindowPos(mouse_pos, imgui.Cond.FirstUseEver, imgui.ImVec2(0, 0))
		imgui.Begin('##mouse', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + (move.v and 0 or imgui.WindowFlags.NoMove) )
			mouse_pos = imgui.GetWindowPos()
			for key, v in ipairs(mouse_keys) do
				if key == 2 then renderWheel() imgui.SetCursorPosY(18) elseif key == 3 then imgui.SetCursorPosY(2) end 
				local size = imgui.CalcTextSize(v[1])
				if isKeyDown(v[2]) then
					imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.GetStyle().Colors[imgui.Col.ButtonActive])
				else
					imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0,0,0,0.4))
				end
				imgui.BeginChild('##'..key, imgui.ImVec2(v[4] and v[4] or size.x+11, v[3] and v[3] or size.y+5), true)
					if v[3] then imgui.SetCursorPosY((v[3]-size.y)/2) end
					imgui.SetCursorPosX((imgui.GetWindowWidth()-size.x)/2)
					imgui.Text(v[1])
				imgui.EndChild()
				imgui.PopStyleColor()
				if key ~= 3 then imgui.SameLine() end
			end
		imgui.End()
		imgui.PopStyleColor()
		imgui.PopStyleVar()
	end
end

function renderWheel()
	if #wheel > 0 then
		local p = imgui.GetCursorScreenPos()
		local c = imgui.GetCursorPos()
		local draw_list = imgui.GetWindowDrawList()
		draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x+36, p.y+34), imgui.GetColorU32(wheel[1][1] > 0 and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImVec4(0,0,0,0)), 10)
		draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y+16), imgui.ImVec2(p.x+36, p.y+49), imgui.GetColorU32(wheel[1][1] < 0 and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImVec4(0,0,0,0)), 10)
		if wheel[1][2] < os.clock() then
			table.remove(wheel, 1)
		end
	end
end

function onScriptTerminate(s)
	if s == thisScript() then
		ini.config.active = keyboard.v
		ini.mouse.active = mouse.v
		ini.config.mode = keyboard_type.v
		ini.config.move = move.v
		ini.config.theme = theme.v
		ini.pos.x, ini.pos.y = keyboard_pos.x, keyboard_pos.y
		ini.mouse.x, ini.mouse.y = mouse_pos.x, mouse_pos.y
		inicfg.save(ini, iniFile)
	end
end

keyboards = {
	{
		{
			{'Esc', 0x1B},
			{'F1', 0x70},
			{'F2', 0x71},
			{'F3', 0x72},
			{'F4', 0x73},
			{'F5', 0x74},
			{'F6', 0x75},
			{'F7', 0x76},
			{'F8', 0x77},
			{'F9', 0x78},
			{'F10', 0x79},
			{'F11', 0x7A},
			{'F12', 0x7B, 23},
			{'PS', 0x2C},
			{'SL', 0x91},
			{'P', 0x13},
		},
		{ 
			{'`', 0xC0},
			{'1', 0x31},
			{'2', 0x32},
			{'3', 0x33},
			{'4', 0x34},
			{'5', 0x35},
			{'6', 0x36},
			{'7', 0x37},
			{'8', 0x38},
			{'9', 0x39},
			{'0', 0x30},
			{'-', 0xBD},
			{'+', 0xBB},
			{'<-', 0x08},
			{'Ins', 0x2D},
			{'Home', 0x24},
			{'PgUp', 0x21},
			{'NL', 0x90},
			{'/', 0x6F},
			{'*', 0x6A},
			{'-', 0x6D},
		},
		{ 
			{'Tab', 0x09},
			{'Q', 0x51},
			{'W', 0x57},
			{'E', 0x45},
			{'R', 0x52},
			{'T', 0x54},
			{'Y', 0x59},
			{'U', 0x55},
			{'I', 0x49},
			{'O', 0x4F},
			{'P', 0x50},
			{'[', 0xDB},
			{']', 0xDD},
			{'\\', 0xDC},
			{'Del', 0x2E},
			{'End', 0x23},
			{'PgDn', 0x22, 6},
			{'7', 0x67},
			{'8', 0x68},
			{'9', 0x69},
			{'\n+', 0x6B},
		},
		{
			{'Caps ', 0x14},
			{'A', 0x41},
			{'S', 0x53},
			{'D', 0x44},
			{'F', 0x46},
			{'G', 0x47},
			{'H', 0x48},
			{'J', 0x4A},
			{'K', 0x4B},
			{'L', 0x4C},
			{';', 0xBA},
			{'\'', 0xDE},
			{' Enter ', 0x0D, 96},
			{'4', 0x64},
			{'5', 0x65},
			{'6', 0x66},
		},
		{
			{' LShift  ', 0xA0},
			{'Z', 0x5A},
			{'X', 0x58},
			{'C', 0x43},
			{'V', 0x56},
			{'B', 0x42},
			{'N', 0x4E},
			{'M', 0x4D},
			{',', 0xBC},
			{'.', 0xBE},
			{'/', 0xBF},
			{' RShift  ', 0xA1, 37},
			{'/\\', 0x26, 37},
			{'1', 0x61},
			{'2', 0x62},
			{'3', 0x63},
			{'\nE', 0x0D},
		},
		{ 
			{'Ctrl', 0xA2},
			{'Win', 0x5B},
			{'Alt', 0xA4},
			{'                             ', 0x20},
			{'Alt', 0xA5},
			{'Win', 0x5C},
			{'Ctrl', 0xA3, 17},
			{'<', 0x25},
			{'\\/', 0x28},
			{'>', 0x27, 16},
			{'0      ', 0x60},
			{'.', 0x6E},
		}
	},
	{ 
		{
			{'Esc', 0x1B},
			{'F1', 0x70},
			{'F2', 0x71},
			{'F3', 0x72},
			{'F4', 0x73},
			{'F5', 0x74},
			{'F6', 0x75},
			{'F7', 0x76},
			{'F8', 0x77},
			{'F9', 0x78},
			{'F10', 0x79},
			{'F11', 0x7A},
			{'F12', 0x7B},
		},
		{
			{'`', 0xC0},
			{'1', 0x31},
			{'2', 0x32},
			{'3', 0x33},
			{'4', 0x34},
			{'5', 0x35},
			{'6', 0x36},
			{'7', 0x37},
			{'8', 0x38},
			{'9', 0x39},
			{'0', 0x30},
			{'-', 0xBD},
			{'+', 0xBB},
			{'<-', 0x08},
			{'Ins', 0x2D},
			{'Home', 0x24},
			{'PU', 0x21},
		},
		{
			{'Tab', 0x09},
			{'Q', 0x51},
			{'W', 0x57},
			{'E', 0x45},
			{'R', 0x52},
			{'T', 0x54},
			{'Y', 0x59},
			{'U', 0x55},
			{'I', 0x49},
			{'O', 0x4F},
			{'P', 0x50},
			{'[', 0xDB},
			{']', 0xDD},
			{'\\', 0xDC},
			{'Del', 0x2E},
			{'End', 0x23},
			{'PD', 0x22},
		},
		{
			{'Caps ', 0x14},
			{'A', 0x41},
			{'S', 0x53},
			{'D', 0x44},
			{'F', 0x46},
			{'G', 0x47},
			{'H', 0x48},
			{'J', 0x4A},
			{'K', 0x4B},
			{'L', 0x4C},
			{';', 0xBA},
			{'\'', 0xDE},
			{' Enter ', 0x0D},
		},
		{
			{' LShift  ', 0xA0},
			{'Z', 0x5A},
			{'X', 0x58},
			{'C', 0x43},
			{'V', 0x56},
			{'B', 0x42},
			{'N', 0x4E},
			{'M', 0x4D},
			{',', 0xBC},
			{'.', 0xBE},
			{'/', 0xBF},
			{' RShift  ', 0xA1, 33},
			{'/\\', 0x26},
		},
		{
			{'Ctrl', 0xA2},
			{'Win', 0x5B},
			{'Alt', 0xA4},
			{'                              ', 0x20},
			{'Alt', 0xA5},
			{'Win', 0x5C},
			{'Ctrl', 0xA3, 10},
			{'<', 0x25},
			{'\\/', 0x28},
			{'>', 0x27},
		}
	},
	{ 
		{
			{'1', 0x31},
			{'2', 0x32},
			{'3', 0x33},
			{'4', 0x34},
			{'5', 0x35},
			{'6', 0x36},
			{'7', 0x37},
			{'8', 0x38},
			{'9', 0x39},
			{'0', 0x30},
		},
		{
			{'N', 0x4E},
			{' Enter ', 0x0D},
		}
	},
	{ 
		{
			{'1', 0x31},
			{'2', 0x32},
			{'3', 0x33},
		},
		{
			{'4', 0x34},
			{'5', 0x35},
			{'6', 0x36},
		},
		{
			{'7', 0x37},
			{'8', 0x38},
			{'9', 0x39},
		},
		{
			{'0', 0x30},
			{'N', 0x4E},
		},
		{
			{' Enter ', 0x0D},
		}
	},
	{ 
		{
			{'Tab', 0x09},
			{'Q', 0x51},
			{'W', 0x57},
			{'E', 0x45},
			{'R', 0x52},
		},
		{
			{'Shift', 0x10},
			{'A', 0x41},
			{'S', 0x53},
			{'D', 0x44},
			{'C', 0x43},
		},
		{
			{'Ctrl', 0xA2},
			{'Alt', 0xA4},
			{'             ', 0x20},
		}
	}
}

mouse_keys = {
	{'LMB', 0x01, 50},
	{'MMB', 0x04},
	{'RMB', 0x02, 50},
	{'FWD', 0x06, _, 53},
	{'BWD', 0x05, _, 53},
}

styles = {
	[0] = function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		style.WindowRounding = 10
		style.ChildWindowRounding = 10
		style.FrameRounding = 6.0

		style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
		style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 17.0
		style.GrabRounding = 16.0

		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 1.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
		colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
		colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
		colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
		colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
		colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
		colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
		colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
		colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
		colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
		colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
		colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
		colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		style.WindowRounding = 10
		style.ChildWindowRounding = 10
		style.FrameRounding = 6.0

		style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
		style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 17.0
		style.GrabRounding = 16.0

		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00)
		colors[clr.TextDisabled]           = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00)
		colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81)
		colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00)
		colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00)
		colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		style.WindowRounding = 10
		style.ChildWindowRounding = 10
		style.FrameRounding = 6.0

		style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
		style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 17.0
		style.GrabRounding = 16.0

		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		colors[clr.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
		colors[clr.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
		colors[clr.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.Separator]              = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
		colors[clr.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
		colors[clr.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
		colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]                 = ImVec4(0.49, 0.14, 0.31, 1.00)
		colors[clr.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00)
		colors[clr.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.20, 0.20, 0.20, 0.50)
		colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		style.WindowRounding = 10
		style.ChildWindowRounding = 10
		style.FrameRounding = 6.0

		style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
		style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 17.0
		style.GrabRounding = 16.0

		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00)
		colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00)
		colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90)
		colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30)
		colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68)
		colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45)
		colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35)
		colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57)
		colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31)
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00)
		colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24)
		colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44)
		colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00)
		colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76)
		colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20)
		colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75)
		colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59)
		colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00)
		colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43)
		colors[clr.TextDisabled]          = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		style.WindowRounding = 10
		style.ChildWindowRounding = 10
		style.FrameRounding = 6.0

		style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
		style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 17.0
		style.GrabRounding = 16.0

		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		colors[clr.Text]                  = ImVec4(0.86, 0.93, 0.89, 0.78)
		colors[clr.TextDisabled]          = ImVec4(0.71, 0.22, 0.27, 1.00)
		colors[clr.WindowBg]              = ImVec4(0.13, 0.14, 0.17, 1.00)
		colors[clr.ChildWindowBg]         = ImVec4(0.20, 0.22, 0.27, 0.58)
		colors[clr.PopupBg]               = ImVec4(0.20, 0.22, 0.27, 0.90)
		colors[clr.Border]                = ImVec4(0.31, 0.31, 1.00, 0.00)
		colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]               = ImVec4(0.20, 0.22, 0.27, 1.00)
		colors[clr.FrameBgHovered]        = ImVec4(0.46, 0.20, 0.30, 0.78)
		colors[clr.FrameBgActive]         = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.TitleBg]               = ImVec4(0.23, 0.20, 0.27, 1.00)
		colors[clr.TitleBgActive]         = ImVec4(0.50, 0.08, 0.26, 1.00)
		colors[clr.TitleBgCollapsed]      = ImVec4(0.20, 0.20, 0.27, 0.75)
		colors[clr.MenuBarBg]             = ImVec4(0.20, 0.22, 0.27, 0.47)
		colors[clr.ScrollbarBg]           = ImVec4(0.20, 0.22, 0.27, 1.00)
		colors[clr.ScrollbarGrab]         = ImVec4(0.09, 0.15, 0.10, 1.00)
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.46, 0.20, 0.30, 0.78)
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.CheckMark]             = ImVec4(0.71, 0.22, 0.27, 1.00)
		colors[clr.SliderGrab]            = ImVec4(0.47, 0.77, 0.83, 0.14)
		colors[clr.SliderGrabActive]      = ImVec4(0.71, 0.22, 0.27, 1.00)
		colors[clr.Button]                = ImVec4(0.47, 0.77, 0.83, 0.14)
		colors[clr.ButtonHovered]         = ImVec4(0.46, 0.20, 0.30, 0.86)
		colors[clr.ButtonActive]          = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.Header]                = ImVec4(0.46, 0.20, 0.30, 0.76)
		colors[clr.HeaderHovered]         = ImVec4(0.46, 0.20, 0.30, 0.86)
		colors[clr.HeaderActive]          = ImVec4(0.50, 0.08, 0.26, 1.00)
		colors[clr.ResizeGrip]            = ImVec4(0.47, 0.77, 0.83, 0.04)
		colors[clr.ResizeGripHovered]     = ImVec4(0.46, 0.20, 0.30, 0.78)
		colors[clr.ResizeGripActive]      = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.PlotLines]             = ImVec4(0.86, 0.93, 0.89, 0.63)
		colors[clr.PlotLinesHovered]      = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.PlotHistogram]         = ImVec4(0.86, 0.93, 0.89, 0.63)
		colors[clr.PlotHistogramHovered]  = ImVec4(0.46, 0.20, 0.30, 1.00)
		colors[clr.TextSelectedBg]        = ImVec4(0.46, 0.20, 0.30, 0.43)
		colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.22, 0.27, 0.73)
		colors[clr.CloseButton]           = ImVec4(0.20, 0.22, 0.27, 1.00)
		colors[clr.CloseButtonHovered]    = ImVec4(0.46, 0.20, 0.30, 0.78)
		colors[clr.CloseButtonActive]     = ImVec4(0.46, 0.20, 0.30, 1.00)
	end,
	function()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		style.WindowRounding = 10
		style.ChildWindowRounding = 10
		style.FrameRounding = 6.0

		style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
		style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
		style.IndentSpacing = 21
		style.ScrollbarSize = 10.0
		style.ScrollbarRounding = 13
		style.GrabMinSize = 17.0
		style.GrabRounding = 16.0

		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		colors[clr.Text]                 = ImVec4(0.92, 0.92, 0.92, 1.00)
		colors[clr.TextDisabled]         = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.06, 0.06, 0.06, 1.00)
		colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.ComboBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.11, 0.11, 0.11, 1.00)
		colors[clr.FrameBgHovered]       = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.FrameBgActive]        = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.TitleBg]              = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.TitleBgActive]        = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]            = ImVec4(0.11, 0.11, 0.11, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.06, 0.06, 0.06, 0.53)
		colors[clr.ScrollbarGrab]        = ImVec4(0.21, 0.21, 0.21, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.47, 0.47, 0.47, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.81, 0.83, 0.81, 1.00)
		colors[clr.CheckMark]            = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.Button]               = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.ButtonHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.ButtonActive]         = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.Header]               = ImVec4(0.51, 0.36, 0.15, 1.00)
		colors[clr.HeaderHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.HeaderActive]         = ImVec4(0.93, 0.65, 0.14, 1.00)
		colors[clr.Separator]            = ImVec4(0.21, 0.21, 0.21, 1.00)
		colors[clr.SeparatorHovered]     = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.SeparatorActive]      = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.ResizeGrip]           = ImVec4(0.21, 0.21, 0.21, 1.00)
		colors[clr.ResizeGripHovered]    = ImVec4(0.91, 0.64, 0.13, 1.00)
		colors[clr.ResizeGripActive]     = ImVec4(0.78, 0.55, 0.21, 1.00)
		colors[clr.CloseButton]          = ImVec4(0.47, 0.47, 0.47, 1.00)
		colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
		colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	end,
}
styles[theme.v]()