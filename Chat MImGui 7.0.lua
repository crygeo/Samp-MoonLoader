script_name('Chat MImGui') -- traducido y adaptado a la codificaci�n espa�ol por jos� | ollydbg
script_version_number(7)
script_author('Katsuro | #Northn')  
  
 
local imgui = require 'mimgui'
local memory = require'memory'
local ffi = require 'ffi'
local bit = require 'bit'
local encoding = require 'encoding'
local inicfg = require 'inicfg'
encoding.default = 'ISO-8859-1'
local u8 = encoding.UTF8
local messages = {}
local sendMessages = {}
local openChat = false
local openColor = 0
local scrollbar = imgui.new.int(0)
local noScroll = false
local max_scroll, current_scroll, setup_current_scroll, lastSelectedMessage = 0, 0, 0, 1
local inputChat = imgui.new.char[290]()
local timestampStatus, showChat = true, true
local editChatLine, editChatLineColor, editChatLineTime = imgui.new.char[290](), imgui.new.char[8](), imgui.new.char[10]()
local layout = ffi.new('char[10]')
local info = ffi.new('char[10]')

--HOOKS
local hook = {hooks = {}}
addEventHandler('onScriptTerminate', function(scr)
    if scr == script.this then
        for i, hook in ipairs(hook.hooks) do
            if hook.status then
                hook.stop()
            end
        end
		inicfg.save(data, 'Chat MImGui')
    end
end)
ffi.cdef [[
    int VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);
    void* VirtualAlloc(void* lpAddress, unsigned long dwSize, unsigned long  flAllocationType, unsigned long flProtect);
    int VirtualFree(void* lpAddress, unsigned long dwSize, unsigned long dwFreeType);
	
	struct stChatEntry 
	{ 
		uint32_t SystemTime; 
		char szPrefix[28]; 
		char szText[144]; 
		uint8_t unknown[64]; 
		int iType; // 2 - text + prefix, 4 - text (server msg), 8 - text (debug) 
		int clTextColor; 
		int clPrefixColor; // or textOnly colour 
	}__attribute__((packed)); 

	typedef struct stChatInfoMin 
	{ 
		struct stChatEntry chatEntry[100]; 
	} chatInfoMin;
	
	typedef void(__cdecl *CMDPROC)(char *); 
	struct stInputInfo 
	{ 
		void *pD3DDevice; 
		void *pDXUTDialog; 
		struct stInputBox *pDXUTEditBox; 
		CMDPROC pCMDs[144]; 
		char szCMDNames[144][33]; 
		int iCMDCount; 
		int iInputEnabled; 
		char szInputBuffer[129]; 
		char szRecallBufffer[10][129]; 
		char szCurrentBuffer[129]; 
		int iCurrentRecall; 
		int iTotalRecalls; 
		CMDPROC pszDefaultCMD; 
	}__attribute__((packed));
	
	typedef char CHAR;
	typedef CHAR *PCHAR;

	int GetLocaleInfoA(int Locale, int LCType, PCHAR lpLCData, int cchData);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
]]
function hook.new(cast, callback, hook_addr, size, trampoline, org_bytes_tramp)
    local size = size or 5
    local trampoline = trampoline or false
    local new_hook, mt = {}, {}
    local detour_addr = tonumber(ffi.cast('intptr_t', ffi.cast('void*', ffi.cast(cast, callback))))
    local void_addr = ffi.cast('void*', hook_addr)
    local old_prot = ffi.new('unsigned long[1]')
    local org_bytes = ffi.new('uint8_t[?]', size)
    ffi.copy(org_bytes, void_addr, size)
    if trampoline then
        local alloc_addr = ffi.gc(ffi.C.VirtualAlloc(nil, size + 5, 0x1000, 0x40), function(addr) ffi.C.VirtualFree(addr, 0, 0x8000) end)
        local trampoline_bytes = ffi.new('uint8_t[?]', size + 5, 0x90)
        if org_bytes_tramp then
            local bytes = {}
            for byte in org_bytes_tramp:gmatch('(%x%x)') do
                table.insert(bytes, tonumber(byte, 16))
            end
            trampoline_bytes = ffi.new('uint8_t[?]', size + 5, bytes)
        else
            ffi.copy(trampoline_bytes, org_bytes, size)
        end
        trampoline_bytes[size] = 0xE9
        ffi.cast('uint32_t*', trampoline_bytes + size + 1)[0] = hook_addr - tonumber(ffi.cast('intptr_t', ffi.cast('void*', ffi.cast(cast, alloc_addr)))) - size
        ffi.copy(alloc_addr, trampoline_bytes, size + 5)
        new_hook.call = ffi.cast(cast, alloc_addr)
        mt = {__call = function(self, ...)
            return self.call(...)
        end}
    else
        new_hook.call = ffi.cast(cast, hook_addr)
        mt = {__call = function(self, ...)
            self.stop()
            local res = self.call(...)
            self.start()
            return res
        end}
    end
    local hook_bytes = ffi.new('uint8_t[?]', size, 0x90)
    hook_bytes[0] = 0xE9
    ffi.cast('uint32_t*', hook_bytes + 1)[0] = detour_addr - hook_addr - 5
    new_hook.status = false
    local function set_status(bool)
        new_hook.status = bool
        ffi.C.VirtualProtect(void_addr, size, 0x40, old_prot)
        ffi.copy(void_addr, bool and hook_bytes or org_bytes, size)
        ffi.C.VirtualProtect(void_addr, size, old_prot[0], old_prot)
    end
    new_hook.stop = function() set_status(false) end
    new_hook.start = function() set_status(true) end
    new_hook.start()
    if org_bytes[0] == 0xE9 or org_bytes[0] == 0xE8 then
        if trampoline then
            print('[WARNING] rewrote another hook (old hook is disabled, through trampoline)')
        else
            print('[WARNING] rewrote another hook')
        end
    end
    table.insert(hook.hooks, new_hook)
    return setmetatable(new_hook, mt)
end
--HOOKS

function load_ini()
	data = inicfg.load(
		{
			
			scrollbar_colors = {
				scrollbar_bg = '0.16|0.29|0.48|0.54',
				scrollbar_cursor = '0.24|0.52|0.88|1',
				scrollbar_cursor_active = '0.26|0.59|0.98|1',
				scrollbar_bg_hovered = '0.26|0.59|0.98|0.4',
				scrollbar_bg_active = '0.26|0.59|0.98|0.67'
			},
			other_colors = {
				chat_bg = '0|0|0|1',
				input_bg = '0.16|0.29|0.48|0.54'
			},
			values = {
				font_size = '15',
				font_name = 'arialbd.ttf',
				line_count = '15'
			}
		}, 'Chat MImGui.ini')
	assert(data, 'Cannot load config')
	local r, g, b, a = data.other_colors.chat_bg:match('(.+)|(.+)|(.+)|(.+)')
	local r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
	colorChat, colorChatBG = imgui.ImVec4(r, g, b, a), imgui.new.float[4](r, g, b, a) 
	local r, g, b, a = data.other_colors.input_bg:match('(.+)|(.+)|(.+)|(.+)')
	local r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
	colorChatInput, colorChatInputBG = imgui.ImVec4(r, g, b, a), imgui.new.float[4](r, g, b, a)
	local r, g, b, a = data.scrollbar_colors.scrollbar_bg:match('(.+)|(.+)|(.+)|(.+)')
	local r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
	colorScrollbar, colorScrollbarBG = imgui.ImVec4(r, g, b, a), imgui.new.float[4](r, g, b, a)
	local r, g, b, a = data.scrollbar_colors.scrollbar_cursor:match('(.+)|(.+)|(.+)|(.+)')
	local r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
	colorChatScrollbarCursor, colorScrollbarCursor = imgui.ImVec4(r, g, b, a), imgui.new.float[4](r, g, b, a)
	local r, g, b, a = data.scrollbar_colors.scrollbar_cursor_active:match('(.+)|(.+)|(.+)|(.+)')
	local r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
	colorActiveChatScrollbarCursor, colorActiveScrollbarCursor = imgui.ImVec4(r, g, b, a), imgui.new.float[4](r, g, b, a)
	local r, g, b, a = data.scrollbar_colors.scrollbar_bg_hovered:match('(.+)|(.+)|(.+)|(.+)')
	local r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
	colorScrollbarBGHovered, colorScrollbarHoveredBG = imgui.ImVec4(r, g, b, a), imgui.new.float[4](r, g, b, a)
	local r, g, b, a = data.scrollbar_colors.scrollbar_bg_active:match('(.+)|(.+)|(.+)|(.+)')
	local r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
	colorScrollbarBGActive, colorScrollbarActiveBG = imgui.ImVec4(r, g, b, a), imgui.new.float[4](r, g, b, a)
	
	local a = tonumber(data.values.line_count)
	chatLinesCount, linesCount = a, imgui.new.int(a)
	fontSize = imgui.new.int(tonumber(data.values.font_size))
end

 
function imgui.TextColoredRGB(text, id)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local col = imgui.Col
	
	local designText = function(text__)
		local pos = imgui.GetCursorPos()
		if sampGetChatDisplayMode() == 2 then
			for i = 1, 1  do
				imgui.SetCursorPos(imgui.ImVec2(pos.x + i, pos.y))
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
				imgui.SetCursorPos(imgui.ImVec2(pos.x - i, pos.y))
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
				imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y + i))
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
				imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y - i))
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
			end
		end
		imgui.SetCursorPos(pos)
	end
	
	if openChat then
		imgui.Selectable('##'..id)
		imgui.SameLine(0)
		if imgui.BeginPopupContextItem() then
			if imgui.Button('Editar', imgui.ImVec2(-1, 0)) then editChatLineId = id imgui.StrCopy(editChatLineColor, messages[id].color:match('{(.+)}')) imgui.StrCopy(editChatLine, messages[id].text) imgui.StrCopy(editChatLineTime, messages[id].timestamp:match('%[(.+)%]')) imgui.OpenPopup('EditChatLine1') end
			if imgui.Button('Copiar al portapapeles') then setClipboardText(u8:decode(messages[id].text)) imgui.CloseCurrentPopup() end
			if imgui.Button('Copiar al chatinput', imgui.ImVec2(-1, 0)) then imgui.StrCopy(inputChat, messages[id].text) imgui.CloseCurrentPopup() end
			if imgui.Button('Borrar', imgui.ImVec2(-1, 0)) then table.remove(messages, id) setup_current_scroll = setup_current_scroll - imgui.GetTextLineHeightWithSpacing() imgui.CloseCurrentPopup() end
			if imgui.BeginPopupModal('EditChatLine1', nil, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
				local width = imgui.GetWindowWidth()
				local text_width = imgui.CalcTextSize('Edici�n de l�nea #'..editChatLineId)
				imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
				imgui.Text(u8'Edici�n de l�nea #'..editChatLineId)
				imgui.Separator()
				imgui.NewLine()
				imgui.Text('Texto:')
				imgui.PushItemWidth(555)
				imgui.InputText('##feditchetlin', editChatLine, ffi.sizeof(editChatLine) - 1)
				imgui.PopItemWidth()
				imgui.SetCursorPosX(98)
				imgui.Text(u8'Color de l�nea:') imgui.SameLine(400) imgui.Text('Tiempo:')
				imgui.SetCursorPosX(82.5)
				imgui.PushItemWidth(120)
				imgui.InputText('##cditnhatline', editChatLineColor, ffi.sizeof(editChatLineColor) - 1) 
				imgui.PopItemWidth()
				imgui.SameLine(78.75 + 286)
				imgui.PushItemWidth(120)
				imgui.InputText('##adilchettine', editChatLineTime, ffi.sizeof(editChatLineTime) - 1) 
				imgui.PopItemWidth()
				imgui.SetCursorPosX(82.5)
				if imgui.Button('Aplicar', imgui.ImVec2(200, 0)) then
					messages[editChatLineId] = {
					
						text = ffi.string(editChatLine),
						color = '{'..ffi.string(editChatLineColor)..'}',
						timestamp = '['..ffi.string(editChatLineTime)..']'
					}
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine(nil, 3)
				if imgui.Button('Cerrar', imgui.ImVec2(200, 0)) then imgui.CloseCurrentPopup() end
				imgui.EndPopup()
			end
			imgui.EndPopup()
		end
		imgui.SetCursorPosX(0)
	end
	
	local text = text:gsub('{(%x%x%x%x%x%x)}', '{%1FF}')

	local color = colors[col.Text]
	local start = 1
	local a, b = text:find('{........}', start)	
	
	while a do
		local t = text:sub(start, a - 1)
		if #t > 0 then
			designText(t)
			imgui.TextColored(color, t)
			imgui.SameLine(nil, 0)
		end

		local clr = text:sub(a + 1, b - 1)
		if clr:upper() == 'STANDART' then color = colors[col.Text]
		else
			clr = tonumber(clr, 16)
			if clr then
				local r = bit.band(bit.rshift(clr, 24), 0xFF)
				local g = bit.band(bit.rshift(clr, 16), 0xFF)
				local b = bit.band(bit.rshift(clr, 8), 0xFF)
				local a = bit.band(clr, 0xFF)
				color = imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
			end
		end

		start = b + 1
		a, b = text:find('{........}', start)
	end
	imgui.NewLine()
	if #text >= start then
		imgui.SameLine(nil, 0)
		designText(text:sub(start))
		imgui.TextColored(color, text:sub(start))
	end
end

imgui.OnInitialize (function() -- Called once

	imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
	
	fonts = {}
	fontsArray = {}
	
	load_ini()
	
	fontChanged, fontSizeChanged = false, false
	
	enableSettingsWindow = imgui.new.bool()
	
	-- imgui.GetIO().WantCaptureMouse = true DONT WORKS
	imgui.GetIO().IniFilename = nil
	imgui.GetStyle().WindowBorderSize = 0
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	imgui.GetIO().Fonts:Clear()
	imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\'..data.values.font_name, fontSize[0], nil, glyph_ranges)
	--imgui.RebuildFonts()
	
	local search, file = findFirstFile(getFolderPath(0x14) .. '\\*.ttf')
	while file do
		table.insert(fonts, file)
		if file == data.values.font_name then fontSelected = imgui.new.int(#fonts - 1) end
		file = findNextFile(search)
	end
	fontsArray = imgui.new['const char*'][#fonts](fonts)
	fontSize[0] = imgui.GetIO().Fonts.ConfigData.Data[0].SizePixels
end)

function TextEditCallback(data)
	if data.EventFlag == 128 then
		if data.EventKey == 3 --[[UP]] then
			if sendMessages[lastSelectedMessage - 1] ~= nil then
				data:DeleteChars(0, data.BufTextLen)
				data:InsertChars(0, u8(sendMessages[lastSelectedMessage - 1]))
				sampSetChatInputText(sendMessages[lastSelectedMessage - 1])
				lastSelectedMessage = lastSelectedMessage - 1
			end
		elseif data.EventKey == 4 then
			if sendMessages[lastSelectedMessage + 1] ~= nil then
				data:DeleteChars(0, data.BufTextLen)
				data:InsertChars(0, u8(sendMessages[lastSelectedMessage + 1]))
				sampSetChatInputText(sendMessages[lastSelectedMessage + 1])
				lastSelectedMessage = lastSelectedMessage + 1
			else
				data:DeleteChars(0, data.BufTextLen)
				data:InsertChars(0, '')
				sampSetChatInputText('')
				lastSelectedMessage = #sendMessages + 1
			end
		end
	elseif data.EventFlag == 64 then
		data:DeleteChars(0, data.BufTextLen)
		data:InsertChars(0, u8(sampGetChatInputText()))
	end
	return 0
end

local TextEditCallback = ffi.cast('int (*)(ImGuiInputTextCallbackData* data)', TextEditCallback)

local chat = imgui.OnFrame(function() return #messages > 0 and not isPauseMenuActive() and sampIsChatVisible() and not sampIsScoreboardOpen() and showChat end, function()
	if fontChanged then
		fontChanged = false
		local glyphRanges = imgui.GetIO().Fonts.Fonts.Data[0].ConfigData.GlyphRanges
		local fontPath = ('%s\\%s'):format(getFolderPath(0x14), fonts[fontSelected[0] + 1])
		imgui.GetIO().Fonts:Clear()
		imgui.GetIO().Fonts:AddFontFromFileTTF(fontPath, fontSize[0], nil, glyphRanges)
		-- Font texture invalidation forces the font texture to rebuild. It is necessary after font modifications
		imgui.InvalidateFontsTexture()
	end
	if fontSizeChanged then
		fontSizeChanged = false
		local fonts = imgui.GetIO().Fonts.ConfigData
		for i = 0, fonts:size() - 1 do
			fonts.Data[i].SizePixels = fontSize[0]
		end
		imgui.GetIO().Fonts:ClearTexData()
		imgui.InvalidateFontsTexture()
	end
end, function(self)
	if not sampIsCursorActive() and openChat == true then sampToggleCursor(true) end
	imgui.CaptureMouseFromApp(openChat)
	imgui.SetNextWindowPos(imgui.ImVec2(2, 10))
	imgui.SetNextWindowSize(imgui.ImVec2(1020, imgui.GetTextLineHeightWithSpacing() * chatLinesCount + 50 + 2))
	imgui.PushStyleColor(imgui.Col.WindowBg, colorChat)
	imgui.SetNextWindowBgAlpha(openColor)
	imgui.Begin('ImGuiChat', nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoSavedSettings)
	if openChat then
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0, 0, 0, 0))
		imgui.PushStyleColor(imgui.Col.FrameBg, colorScrollbar)
		imgui.PushStyleColor(imgui.Col.FrameBgHovered, colorScrollbarBGHovered)
		imgui.PushStyleColor(imgui.Col.FrameBgActive, colorScrollbarBGActive)
		imgui.PushStyleColor(imgui.Col.SliderGrab, colorChatScrollbarCursor)
		imgui.PushStyleColor(imgui.Col.SliderGrabActive, colorActiveChatScrollbarCursor)
		imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 12)
		imgui.PushStyleVarFloat(imgui.StyleVar.GrabRounding, 12)
		if imgui.VSliderInt('##slidercontent', imgui.ImVec2(15, imgui.GetTextLineHeightWithSpacing() * chatLinesCount + 10 + 2), scrollbar, 0, max_scroll) then
			noScroll = scrollbar[0] ~= 0
			setup_current_scroll = max_scroll - scrollbar[0]
		end
		imgui.PopStyleVar(2)
		imgui.PopStyleColor(6)
	end
	imgui.SetCursorPos(imgui.ImVec2(30, 15))
	--imgui.SetNextWindowContentSize(imgui.ImVec2(1500, 0))
	imgui.BeginChild('##content', imgui.ImVec2(0, imgui.GetTextLineHeightWithSpacing() * chatLinesCount + 2), false, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
	--imgui.SetWindowFontScale(1.1)
	local clipper = imgui.ImGuiListClipper(#messages)
	while clipper:Step() do
		for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
			if messages[i] ~= nil then
				imgui.TextColoredRGB(messages[i].color..(timestampStatus and messages[i].timestamp..' ' or '')..messages[i].text, i)
			end
		end
	end
	current_scroll, max_scroll = imgui.GetScrollY(), imgui.GetScrollMaxY()
	imgui.SetScrollY(setup_current_scroll)
	imgui.EndChild()
	if openChat then
		imgui.SetCursorPosX(30)
		--imgui.SetKeyboardFocusHere()
		--imgui.PushItemWidth(980)
		local off = imgui.GetStyle().ItemSpacing.y + imgui.CalcTextSize(res).x
		ffi.C.GetKeyboardLayoutNameA(layout)
		ffi.C.GetLocaleInfoA(tonumber(ffi.string(layout), 16), 0x3, info, ffi.sizeof(info))
		local res = ffi.string(info):sub(1, 2)
		local cur = imgui.GetCursorPosY()
		imgui.PushStyleColor(imgui.Col.FrameBg, colorChatInput)
		if imgui.InputText("##meptexet", inputChat, ffi.sizeof(inputChat) - 1, imgui.InputTextFlags.CallbackHistory + imgui.InputTextFlags.CallbackCompletion, TextEditCallback) then sampSetChatInputText(u8:decode(ffi.string(inputChat))) end
		imgui.PopStyleColor()
		if reclaim_focus == true then
			imgui.SetKeyboardFocusHere(-1)
			reclaim_focus = false
		end
		imgui.SameLine(nil, 3)
		imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 3)
		imgui.PushStyleColor(imgui.Col.Button, colorChatInput)
		imgui.PushStyleColor(imgui.Col.ButtonHovered, colorChatInput)
		imgui.PushStyleColor(imgui.Col.ButtonActive, colorChatInput)
		imgui.Button(res)
		imgui.PopStyleColor(3)
		imgui.PopStyleVar()
	end
	imgui.End()
	imgui.PopStyleColor()
end)

local settingsWindow = imgui.OnFrame(function() return enableSettingsWindow and enableSettingsWindow[0] end, function()
	local sizeX, sizeY = getScreenResolution()
	imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(500, 345), imgui.Cond.FirstUseEver)
	imgui.Begin('Chat MImGui | Ajustes | Autor: #Northn', enableSettingsWindow)
	local width = imgui.GetWindowWidth()
	local text_width = imgui.CalcTextSize(u8'Interacci�n de fuentes:')
	imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
	imgui.Text(u8'Interacci�n de fuentes:')
	local font = imgui.GetIO().Fonts.Fonts.Data[0]
	imgui.Text('Fuente actual: %s', font:GetDebugName())
	if imgui.Combo('Elegir fuente', fontSelected, fontsArray, #fonts) then
		fontChanged = true
		data.values.font_name = fonts[fontSelected[0] + 1]
	end
	if imgui.SliderInt(u8'Tama�o de fuente', fontSize, 4, 30) then
		fontSizeChanged = true
		data.values.font_size = fontSize[0]
	end
	if imgui.SliderInt(u8'N�mero de l�neas##li', linesCount, 4, 72) then
		chatLinesCount = linesCount[0]
		data.values.line_count = linesCount[0]
	end
	imgui.Separator()
	local text_width = imgui.CalcTextSize(u8'Interacci�n con los colores:')
	imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
	imgui.Text(u8'Interacci�n con los colores:')
	imgui.Text('Color de fondo:')
	imgui.SameLine(nil, 3)
	if imgui.ColorEdit4('Color de fondo de chat##a', colorChatBG, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel) then
		colorChat = imgui.ImVec4(colorChatBG[0], colorChatBG[1], colorChatBG[2], colorChatBG[3])
		data.other_colors.chat_bg = colorChatBG[0]..'|'..colorChatBG[1]..'|'..colorChatBG[2]..'|'..colorChatBG[3]
	end
	imgui.Text('Color del chatinput:')
	imgui.SameLine(nil, 3)
	if imgui.ColorEdit4('Color del chatinput##b', colorChatInputBG, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel) then
		colorChatInput = imgui.ImVec4(colorChatInputBG[0], colorChatInputBG[1], colorChatInputBG[2], colorChatInputBG[3])
		data.other_colors.input_bg = colorChatInputBG[0]..'|'..colorChatInputBG[1]..'|'..colorChatInputBG[2]..'|'..colorChatInputBG[3]
	end
	imgui.Text('Color de fondo de la barra de desplazamiento:')
	imgui.SameLine(nil, 3)
	if imgui.ColorEdit4('Color de fondo de la barra de desplazamiento##c', colorScrollbarBG, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel) then
		colorScrollbar = imgui.ImVec4(colorScrollbarBG[0], colorScrollbarBG[1], colorScrollbarBG[2], colorScrollbarBG[3])
		data.scrollbar_colors.scrollbar_bg = colorScrollbarBG[0]..'|'..colorScrollbarBG[1]..'|'..colorScrollbarBG[2]..'|'..colorScrollbarBG[3]
	end
	imgui.Text('Color de fondo (si cursor esta sobre la barra de desplazamiento):')
	imgui.SameLine(nil, 3)
	if imgui.ColorEdit4('Color barra de desplazamiento##d340', colorScrollbarHoveredBG, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel) then
		colorScrollbarBGHovered = imgui.ImVec4(colorScrollbarHoveredBG[0], colorScrollbarHoveredBG[1], colorScrollbarHoveredBG[2], colorScrollbarHoveredBG[3])
		data.scrollbar_colors.scrollbar_bg_hovered = colorScrollbarHoveredBG[0]..'|'..colorScrollbarHoveredBG[1]..'|'..colorScrollbarHoveredBG[2]..'|'..colorScrollbarHoveredBG[3]
	end
	imgui.Text('Color de fondo activo de la barra de desplazamiento:')
	imgui.SameLine(nil, 3)
	if imgui.ColorEdit4('Color de fondo activo de la barra de desplazamiento##e', colorScrollbarActiveBG, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel) then
		colorScrollbarBGActive = imgui.ImVec4(colorScrollbarActiveBG[0], colorScrollbarActiveBG[1], colorScrollbarActiveBG[2], colorScrollbarActiveBG[3])
		data.scrollbar_colors.scrollbar_bg_active = colorScrollbarActiveBG[0]..'|'..colorScrollbarActiveBG[1]..'|'..colorScrollbarActiveBG[2]..'|'..colorScrollbarActiveBG[3]
	end
	imgui.Text('Color de arrastre de la barra de desplazamiento:')
	imgui.SameLine(nil, 3)
	if imgui.ColorEdit4('Color de fondo activo de la barra de desplazamiento##qt', colorScrollbarCursor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel) then
		colorChatScrollbarCursor = imgui.ImVec4(colorScrollbarCursor[0], colorScrollbarCursor[1], colorScrollbarCursor[2], colorScrollbarCursor[3])
		data.scrollbar_colors.scrollbar_cursor = colorScrollbarCursor[0]..'|'..colorScrollbarCursor[1]..'|'..colorScrollbarCursor[2]..'|'..colorScrollbarCursor[3]
	end
	imgui.Text('Color de arrastre activo de la barra de desplazamiento:')
	imgui.SameLine(nil, 3)
	if imgui.ColorEdit4('Color de arrastre activo de la barra de desplazamiento##8e', colorActiveScrollbarCursor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel) then
		colorActiveChatScrollbarCursor = imgui.ImVec4(colorActiveScrollbarCursor[0], colorActiveScrollbarCursor[1], colorActiveScrollbarCursor[2], colorActiveScrollbarCursor[3])
		data.scrollbar_colors.scrollbar_cursor_active = colorActiveScrollbarCursor[0]..'|'..colorActiveScrollbarCursor[1]..'|'..colorActiveScrollbarCursor[2]..'|'..colorActiveScrollbarCursor[3]
	end
	if imgui.Button("Guardar configuracion") then 
		inicfg.save(data, 'Chat MImGui')
	end
end)

chat.HideCursor = true

function ARGBtoRGB(color) return bit32 or bit.band(color, 0xFFFFFF) end

function sampChatHook(this, type, text, prefix, color, pcolor)
	--if #messages > 100 then table.remove(messages, 1) end
	local color1 = bit.tohex(ARGBtoRGB(color)):gsub('^00', '')
	local texta = ffi.string(text)
	if type == 2 then
		local prefixcolor = bit.tohex(ARGBtoRGB(pcolor)):gsub('^00', '')
		texta = '{'..prefixcolor..'}'..ffi.string(prefix)..': {'..color1..'}'..texta
	end
	table.insert(messages, { text = u8(texta), color = '{'..color1..'}', timestamp = os.date('[%H:%M:%S]') })
	sampChatHook(this, type, text, prefix, color, pcolor)
end

function sampInputHook(this, text, carretOnStartPos)
	imgui.StrCopy(inputChat, u8(ffi.string(text)))
	sampInputHook(this, text, carretOnStartPos)
end

function sampInputEnableHook(this)
	if isSampfuncsConsoleActive() then return end
	reclaim_focus = true
	openChat = true
	pInput.iInputEnabled = 1
end

function sampInputDisableHook(this)
	openChat = false
	pInput.iInputEnabled = 0
	sampToggleCursor(false)
	noScroll = false
end

function main()
	--memory.fill(getModuleHandle('samp.dll') + 0x643fd,  0x90, 5, true)
	sampInputHook = hook.new('void(__thiscall *)(void* this, const char* text, bool carretOnStartPos)', sampInputHook, getModuleHandle('samp.dll') + 0x80F60, 5, false, '8B 44 24 04 56')
	sampInputEnableHook = hook.new('void(__thiscall *)(void* this)', sampInputEnableHook, getModuleHandle('samp.dll') + 0x657E0, 5, false, '83 EC 10 56 8B')
	sampInputDisableHook = hook.new('void(__thiscall *)(void* this)', sampInputDisableHook, getModuleHandle('samp.dll') + 0x658E0, 5, false, '56 8B F1 8B 86')
	
	--sampInputGetTextHook = hook.new('void(__thiscall *)(void *this)', sampInputGetTextHook, getModuleHandle('samp.dll') + 0x81030)
	--sampInputGetTextHook = hook.new('void(__thiscall *)(void *this, const char* text)', sampInputGetTextHook, getModuleHandle('samp.dll') + 0x81030) DO NOT SURE, DONT USE BOTH OF THEM
	while not isSampAvailable() do wait(50) end
	local chatEntry = ffi.cast('chatInfoMin*', sampGetChatInfoPtr() + 306).chatEntry
	pInput = ffi.cast('struct stInputInfo*', sampGetInputInfoPtr())[0]
	for i = 0, 99 do
		if chatEntry[i].clTextColor ~= 0 and chatEntry[i].szText ~= '' then
			local color = bit.tohex(ARGBtoRGB(chatEntry[i].clTextColor)):gsub('^00', '')
			local text = ffi.string(chatEntry[i].szText)
			if chatEntry[i].iType == 2 then
				local prefixcolor = bit.tohex(ARGBtoRGB(chatEntry[i].clPrefixColor)):gsub('^00', '')
				text = '{'..prefixcolor..'}'..ffi.string(chatEntry[i].szPrefix)..' {'..color..'}'..text
			end
			table.insert(messages, { text = u8(text), color = '{'..color..'}', timestamp = os.date('[%H:%M:%S]', chatEntry[i].SystemTime) })
		end
	end
	sampChatHook = hook.new('void(__thiscall *)(void *this, uint32_t type, const char* text, const char* prefix, uint32_t color, uint32_t pcolor)', sampChatHook, getModuleHandle('samp.dll') + 0x64010, 5, false, '55 56 8B E9 57')
	
	--sampInputGetTextHook = hook.new('char *(__thiscall *)(void *this)', sampInputGetTextHook, getModuleHandle('samp.dll') + 0x81030)
	memory.setuint8(sampGetBase() + 0x71480, 0xEB, true)
	timestampStatus = ffi.cast('uint8_t*', sampGetChatInfoPtr() + 12)[0] == 1
	lua_thread.create(function()
		while true do wait(0)
			if noScroll == false then
				while max_scroll - current_scroll ~= 0 and noScroll ~= true do
					local scroll_count = 0
					if max_scroll - current_scroll > 360 then scroll_count = 48
					elseif max_scroll - current_scroll > 240 then scroll_count = 32
					elseif max_scroll - current_scroll > 120 then scroll_count = 16
					else scroll_count = 4 end
					setup_current_scroll = setup_current_scroll + scroll_count
					wait(20)
				end
				scrollbar[0] = 0
			end
		end
	end)
	while true do wait(0)
		if openChat == true then
			if openColor < colorChatBG[3] then
				wait(500)
				if openChat == true then
					for i = 0, colorChatBG[3], 0.05 do
						openColor = i
						wait(20)
					end
					while openChat do wait(0) end
				end
			end
		else
			if openColor > 0 then
				wait(200)
				while openColor > 0 do wait(20) openColor = openColor - 0.05 end
				openColor = 0
			end
		end
	end
end

addEventHandler('onWindowMessage', function(msg, wparam)
	if msg == 0x0008 then openChat = false showChat = true end
    if msg == 256 then
		if wparam == 0x1B --[[ESC]] and openChat == true then
			openChat = false
			consumeWindowMessage(true, false)
			noScroll = false
			pInput.iInputEnabled = 0
			sampToggleCursor(openChat)
		elseif wparam == 0x74 --[[F5]] then showChat = false  end

	 

	elseif msg == 257 then
		if openChat == true then
			if wparam == 0x0D --[[ENTER]] then
				local text = u8:decode(ffi.string(inputChat))
				if text == '/timestamp' then
					timestampStatus = not timestampStatus
				end
				if text == '/chconfig' then enableSettingsWindow[0] = not enableSettingsWindow[0]
				else sampProcessChatInput(text) end
				openChat = false
				consumeWindowMessage(true, false)
				noScroll = false
				if text ~= '' then
					table.insert(sendMessages, text)
					imgui.StrCopy(inputChat, '')
					lastSelectedMessage = #sendMessages + 1
				end
				sampToggleCursor(openChat)
				pInput.iInputEnabled = 0
			elseif wparam == 0x75 --[[F6]] then
				openChat = false
				pInput.iInputEnabled = 0
				sampToggleCursor(false)
				consumeWindowMessage(true, false)
				noScroll = false
			end
		end
		if wparam == 0x21 --[[PAGE DOWN]] then 
			if setup_current_scroll - 200 >= 0 then setup_current_scroll = setup_current_scroll - 200
			else setup_current_scroll = 0 end
			noScroll = true
		elseif wparam == 0x22 --[[PAGE UP]] then
			if setup_current_scroll + 150 <= max_scroll then setup_current_scroll = setup_current_scroll + 200 noScroll = true
			else setup_current_scroll = max_scroll noScroll = false end
		elseif wparam == 0x74 --[[F5]] then
			showChat = true
		end
	elseif msg == 0x020a --[[MOUSE SCROLL]] and openChat == true then
		local btn, delta = splitsigned(ffi.cast('int32_t', wparam))
		noScroll = true
		if delta > 0 then
			if setup_current_scroll - 40 >= 0 then
				scrollbar[0] = max_scroll - setup_current_scroll + 40
				setup_current_scroll = setup_current_scroll - 40
			else
				scrollbar[0] = max_scroll
				setup_current_scroll = 0
			end
		elseif delta < 0 then
			if setup_current_scroll + 40 <= max_scroll then
				scrollbar[0] = max_scroll - setup_current_scroll - 40
				setup_current_scroll = setup_current_scroll + 40
			else
				scrollbar[0] = 0
				setup_current_scroll = max_scroll
				noScroll = false
			end
		end
	end
end)

function splitsigned(n) 
	n = tonumber(n)
	local x, y = bit.band(n, 0xffff), bit.rshift(n, 16)
	if x >= 0x8000 then x = x-0xffff end
	if y >= 0x8000 then y = y-0xffff end
	return x, y
end