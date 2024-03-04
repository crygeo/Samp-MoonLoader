-- This file is part of SA MoonLoader package.
-- Licensed under the MIT License.
-- Copyright (c) 2016, BlastHack Team <blast.hk>


local keys = {
	VK_LBUTTON = 0x01,
	VK_RBUTTON = 0x02,
	VK_CANCEL = 0x03,
	VK_MBUTTON = 0x04,
	VK_XBUTTON1 = 0x05,
	VK_XBUTTON2 = 0x06,
	VK_BACK = 0x08,
	VK_TAB = 0x09,
	VK_CLEAR = 0x0C,
	VK_RETURN = 0x0D,
	VK_SHIFT = 0x10,
	VK_CONTROL = 0x11,
	VK_MENU = 0x12,
	VK_PAUSE = 0x13,
	VK_CAPITAL = 0x14,
	VK_KANA = 0x15,
	VK_JUNJA = 0x17,
	VK_FINAL = 0x18,
	VK_KANJI = 0x19,
	VK_ESCAPE = 0x1B,
	VK_CONVERT = 0x1C,
	VK_NONCONVERT = 0x1D,
	VK_ACCEPT = 0x1E,
	VK_MODECHANGE = 0x1F,
	VK_SPACE = 0x20,
	VK_PRIOR = 0x21,
	VK_NEXT = 0x22,
	VK_END = 0x23,
	VK_HOME = 0x24,
	VK_LEFT = 0x25,
	VK_UP = 0x26,
	VK_RIGHT = 0x27,
	VK_DOWN = 0x28,
	VK_SELECT = 0x29,
	VK_PRINT = 0x2A,
	VK_EXECUTE = 0x2B,
	VK_SNAPSHOT = 0x2C,
	VK_INSERT = 0x2D,
	VK_DELETE = 0x2E,
	VK_HELP = 0x2F,
	VK_0 = 0x30,
	VK_1 = 0x31,
	VK_2 = 0x32,
	VK_3 = 0x33,
	VK_4 = 0x34,
	VK_5 = 0x35,
	VK_6 = 0x36,
	VK_7 = 0x37,
	VK_8 = 0x38,
	VK_9 = 0x39,
	VK_A = 0x41,
	VK_B = 0x42,
	VK_C = 0x43,
	VK_D = 0x44,
	VK_E = 0x45,
	VK_F = 0x46,
	VK_G = 0x47,
	VK_H = 0x48,
	VK_I = 0x49,
	VK_J = 0x4A,
	VK_K = 0x4B,
	VK_L = 0x4C,
	VK_M = 0x4D,
	VK_N = 0x4E,
	VK_O = 0x4F,
	VK_P = 0x50,
	VK_Q = 0x51,
	VK_R = 0x52,
	VK_S = 0x53,
	VK_T = 0x54,
	VK_U = 0x55,
	VK_V = 0x56,
	VK_W = 0x57,
	VK_X = 0x58,
	VK_Y = 0x59,
	VK_Z = 0x5A,
	VK_LWIN = 0x5B,
	VK_RWIN = 0x5C,
	VK_APPS = 0x5D,
	VK_SLEEP = 0x5F,
	VK_NUMPAD0 = 0x60,
	VK_NUMPAD1 = 0x61,
	VK_NUMPAD2 = 0x62,
	VK_NUMPAD3 = 0x63,
	VK_NUMPAD4 = 0x64,
	VK_NUMPAD5 = 0x65,
	VK_NUMPAD6 = 0x66,
	VK_NUMPAD7 = 0x67,
	VK_NUMPAD8 = 0x68,
	VK_NUMPAD9 = 0x69,
	VK_MULTIPLY = 0x6A,
	VK_ADD = 0x6B,
	VK_SEPARATOR = 0x6C,
	VK_SUBTRACT = 0x6D,
	VK_DECIMAL = 0x6E,
	VK_DIVIDE = 0x6F,
	VK_F1 = 0x70,
	VK_F2 = 0x71,
	VK_F3 = 0x72,
	VK_F4 = 0x73,
	VK_F5 = 0x74,
	VK_F6 = 0x75,
	VK_F7 = 0x76,
	VK_F8 = 0x77,
	VK_F9 = 0x78,
	VK_F10 = 0x79,
	VK_F11 = 0x7A,
	VK_F12 = 0x7B,
	VK_F13 = 0x7C,
	VK_F14 = 0x7D,
	VK_F15 = 0x7E,
	VK_F16 = 0x7F,
	VK_F17 = 0x80,
	VK_F18 = 0x81,
	VK_F19 = 0x82,
	VK_F20 = 0x83,
	VK_F21 = 0x84,
	VK_F22 = 0x85,
	VK_F23 = 0x86,
	VK_F24 = 0x87,
	VK_NUMLOCK = 0x90,
	VK_SCROLL = 0x91,
	VK_OEM_FJ_JISHO = 0x92,
	VK_OEM_FJ_MASSHOU = 0x93,
	VK_OEM_FJ_TOUROKU = 0x94,
	VK_OEM_FJ_LOYA = 0x95,
	VK_OEM_FJ_ROYA = 0x96,
	VK_LSHIFT = 0xA0,
	VK_RSHIFT = 0xA1,
	VK_LCONTROL = 0xA2,
	VK_RCONTROL = 0xA3,
	VK_LMENU = 0xA4,
	VK_RMENU = 0xA5,
	VK_BROWSER_BACK = 0xA6,
	VK_BROWSER_FORWARD = 0xA7,
	VK_BROWSER_REFRESH = 0xA8,
	VK_BROWSER_STOP = 0xA9,
	VK_BROWSER_SEARCH = 0xAA,
	VK_BROWSER_FAVORITES = 0xAB,
	VK_BROWSER_HOME = 0xAC,
	VK_VOLUME_MUTE = 0xAD,
	VK_VOLUME_DOWN = 0xAE,
	VK_VOLUME_UP = 0xAF,
	VK_MEDIA_NEXT_TRACK = 0xB0,
	VK_MEDIA_PREV_TRACK = 0xB1,
	VK_MEDIA_STOP = 0xB2,
	VK_MEDIA_PLAY_PAUSE = 0xB3,
	VK_LAUNCH_MAIL = 0xB4,
	VK_LAUNCH_MEDIA_SELECT = 0xB5,
	VK_LAUNCH_APP1 = 0xB6,
	VK_LAUNCH_APP2 = 0xB7,
	VK_OEM_1 = 0xBA,
	VK_OEM_PLUS = 0xBB,
	VK_OEM_COMMA = 0xBC,
	VK_OEM_MINUS = 0xBD,
	VK_OEM_PERIOD = 0xBE,
	VK_OEM_2 = 0xBF,
	VK_OEM_3 = 0xC0,
	VK_ABNT_C1 = 0xC1,
	VK_ABNT_C2 = 0xC2,
	VK_OEM_4 = 0xDB,
	VK_OEM_5 = 0xDC,
	VK_OEM_6 = 0xDD,
	VK_OEM_7 = 0xDE,
	VK_OEM_8 = 0xDF,
	VK_OEM_AX = 0xE1,
	VK_OEM_102 = 0xE2,
	VK_ICO_HELP = 0xE3,
	VK_PROCESSKEY = 0xE5,
	VK_ICO_CLEAR = 0xE6,
	VK_PACKET = 0xE7,
	VK_OEM_RESET = 0xE9,
	VK_OEM_JUMP = 0xEA,
	VK_OEM_PA1 = 0xEB,
	VK_OEM_PA2 = 0xEC,
	VK_OEM_PA3 = 0xED,
	VK_OEM_WSCTRL = 0xEE,
	VK_OEM_CUSEL = 0xEF,
	VK_OEM_ATTN = 0xF0,
	VK_OEM_FINISH = 0xF1,
	VK_OEM_COPY = 0xF2,
	VK_OEM_AUTO = 0xF3,
	VK_OEM_ENLW = 0xF4,
	VK_OEM_BACKTAB = 0xF5,
	VK_ATTN = 0xF6,
	VK_CRSEL = 0xF7,
	VK_EXSEL = 0xF8,
	VK_EREOF = 0xF9,
	VK_PLAY = 0xFA,
	VK_ZOOM = 0xFB,
	VK_PA1 = 0xFD,
	VK_OEM_CLEAR = 0xFE,
}

local categorys = {
    Mouse = 0,
    Keyboard = 1,
    Nummer = 2,
    Numpad = 3,
    Letter = 4,
    KeyAccion = 5
}

local keyNames = {
    [keys.VK_RBUTTON] = { category = categorys.Mouse, name = "Right Button", value = keys.VK_RBUTTON },
    [keys.VK_LBUTTON] = { category = categorys.Mouse, name = "Left Button", value = keys.VK_LBUTTON },
    [keys.VK_CANCEL] = { category = categorys.Mouse, name = "Cancel", value = keys.VK_CANCEL },
    [keys.VK_MBUTTON] = { category = categorys.Mouse, name = "Middle Button", value = keys.VK_MBUTTON },
    [keys.VK_XBUTTON1] = { category = categorys.Mouse, name = "X Button 1", value = keys.VK_XBUTTON1 },
    [keys.VK_XBUTTON2] = { category = categorys.Mouse, name = "X Button 2", value = keys.VK_XBUTTON2 },
    [keys.VK_BACK] = { category = categorys.Keyboard, name = "Backspace", value = keys.VK_BACK },
    [keys.VK_TAB] = { category = categorys.Keyboard, name = "Tab", value = keys.VK_TAB },
    [keys.VK_CLEAR] = { category = categorys.Keyboard, name = "Clear", value = keys.VK_CLEAR },
    [keys.VK_RETURN] = { category = categorys.Keyboard, name = "Enter", value = keys.VK_RETURN },
    --[keys.VK_SHIFT] = { category = categorys.Keyboard, name = "Shift", value = keys.VK_SHIFT },
    --[keys.VK_CONTROL] = { category = categorys.Keyboard, name = "Ctrl", value = keys.VK_CONTROL },
    --[keys.VK_MENU] = { category = categorys.Keyboard, name = "Alt", value = keys.VK_MENU },
    [keys.VK_PAUSE] = { category = categorys.Keyboard, name = "Pause", value = keys.VK_PAUSE },
    [keys.VK_CAPITAL] = { category = categorys.Keyboard, name = "Caps Lock", value = keys.VK_CAPITAL },
    [keys.VK_KANA] = { category = categorys.Keyboard, name = "Kana", value = keys.VK_KANA },
    [keys.VK_JUNJA] = { category = categorys.Keyboard, name = "Junja", value = keys.VK_JUNJA },
    [keys.VK_FINAL] = { category = categorys.Keyboard, name = "Final", value = keys.VK_FINAL },
    [keys.VK_KANJI] = { category = categorys.Keyboard, name = "Kanji", value = keys.VK_KANJI },
    [keys.VK_ESCAPE] = { category = categorys.Keyboard, name = "Esc", value = keys.VK_ESCAPE },
    [keys.VK_CONVERT] = { category = categorys.Keyboard, name = "Convert", value = keys.VK_CONVERT },
    [keys.VK_NONCONVERT] = { category = categorys.Keyboard, name = "Non Convert", value = keys.VK_NONCONVERT },
    [keys.VK_ACCEPT] = { category = categorys.Keyboard, name = "Accept", value = keys.VK_ACCEPT },
    [keys.VK_MODECHANGE] = { category = categorys.Keyboard, name = "Mode Change", value = keys.VK_MODECHANGE },
    [keys.VK_SPACE] = { category = categorys.Keyboard, name = "Space", value = keys.VK_SPACE },
    [keys.VK_PRIOR] = { category = categorys.Keyboard, name = "Page Up", value = keys.VK_PRIOR },
    [keys.VK_NEXT] = { category = categorys.Keyboard, name = "Page Down", value = keys.VK_NEXT },
    [keys.VK_END] = { category = categorys.Keyboard, name = "End", value = keys.VK_END },
    [keys.VK_HOME] = { category = categorys.Keyboard, name = "Home", value = keys.VK_HOME },
    [keys.VK_LEFT] = { category = categorys.Keyboard, name = "Arrow Left", value = keys.VK_LEFT },
    [keys.VK_UP] = { category = categorys.Keyboard, name = "Arrow Up", value = keys.VK_UP },
    [keys.VK_RIGHT] = { category = categorys.Keyboard, name = "Arrow Right", value = keys.VK_RIGHT },
    [keys.VK_DOWN] = { category = categorys.Keyboard, name = "Arrow Down", value = keys.VK_DOWN },
    [keys.VK_SELECT] = { category = categorys.Keyboard, name = "Select", value = keys.VK_SELECT },
    [keys.VK_PRINT] = { category = categorys.Keyboard, name = "Print", value = keys.VK_PRINT },
    [keys.VK_EXECUTE] = { category = categorys.Keyboard, name = "Execute", value = keys.VK_EXECUTE },
    [keys.VK_SNAPSHOT] = { category = categorys.Keyboard, name = "Print Screen", value = keys.VK_SNAPSHOT },
    [keys.VK_INSERT] = { category = categorys.Keyboard, name = "Insert", value = keys.VK_INSERT },
    [keys.VK_DELETE] = { category = categorys.Keyboard, name = "Delete", value = keys.VK_DELETE },
    [keys.VK_HELP] = { category = categorys.Keyboard, name = "Help", value = keys.VK_HELP },
    [keys.VK_0] = { category = categorys.Nummer, name = "0", value = keys.VK_0 },
    [keys.VK_1] = { category = categorys.Nummer, name = "1", value = keys.VK_1 },
    [keys.VK_2] = { category = categorys.Nummer, name = "2", value = keys.VK_2 },
    [keys.VK_3] = { category = categorys.Nummer, name = "3", value = keys.VK_3 },
    [keys.VK_4] = { category = categorys.Nummer, name = "4", value = keys.VK_4 },
    [keys.VK_5] = { category = categorys.Nummer, name = "5", value = keys.VK_5 },
    [keys.VK_6] = { category = categorys.Nummer, name = "6", value = keys.VK_6 },
    [keys.VK_7] = { category = categorys.Nummer, name = "7", value = keys.VK_7 },
    [keys.VK_8] = { category = categorys.Nummer, name = "8", value = keys.VK_8 },
    [keys.VK_9] = { category = categorys.Nummer, name = "9", value = keys.VK_9 },
    [keys.VK_A] = { category = categorys.Letter, name = "A", value = keys.VK_A },
    [keys.VK_B] = { category = categorys.Letter, name = "B", value = keys.VK_B },
    [keys.VK_C] = { category = categorys.Letter, name = "C", value = keys.VK_C },
    [keys.VK_D] = { category = categorys.Letter, name = "D", value = keys.VK_D },
    [keys.VK_E] = { category = categorys.Letter, name = "E", value = keys.VK_E },
    [keys.VK_F] = { category = categorys.Letter, name = "F", value = keys.VK_F },
    [keys.VK_G] = { category = categorys.Letter, name = "G", value = keys.VK_G },
    [keys.VK_H] = { category = categorys.Letter, name = "H", value = keys.VK_H },
    [keys.VK_I] = { category = categorys.Letter, name = "I", value = keys.VK_I },
    [keys.VK_J] = { category = categorys.Letter, name = "J", value = keys.VK_J },
    [keys.VK_K] = { category = categorys.Letter, name = "K", value = keys.VK_K },
    [keys.VK_L] = { category = categorys.Letter, name = "L", value = keys.VK_L },
    [keys.VK_M] = { category = categorys.Letter, name = "M", value = keys.VK_M },
    [keys.VK_N] = { category = categorys.Letter, name = "N", value = keys.VK_N },
    [keys.VK_O] = { category = categorys.Letter, name = "O", value = keys.VK_O },
    [keys.VK_P] = { category = categorys.Letter, name = "P", value = keys.VK_P },
    [keys.VK_Q] = { category = categorys.Letter, name = "Q", value = keys.VK_Q },
    [keys.VK_R] = { category = categorys.Letter, name = "R", value = keys.VK_R },
    [keys.VK_S] = { category = categorys.Letter, name = "S", value = keys.VK_S },
    [keys.VK_T] = { category = categorys.Letter, name = "T", value = keys.VK_T },
    [keys.VK_U] = { category = categorys.Letter, name = "U", value = keys.VK_U },
    [keys.VK_V] = { category = categorys.Letter, name = "V", value = keys.VK_V },
    [keys.VK_W] = { category = categorys.Letter, name = "W", value = keys.VK_W },
    [keys.VK_X] = { category = categorys.Letter, name = "X", value = keys.VK_X },
    [keys.VK_Y] = { category = categorys.Letter, name = "Y", value = keys.VK_Y },
    [keys.VK_Z] = { category = categorys.Letter, name = "Z", value = keys.VK_Z },
    [keys.VK_LWIN] = { category = categorys.Keyboard, name = "Left Windows", value = keys.VK_LWIN },
    [keys.VK_RWIN] = { category = categorys.Keyboard, name = "Right Windows", value = keys.VK_RWIN },
    [keys.VK_APPS] = { category = categorys.Keyboard, name = "Apps", value = keys.VK_APPS },
    [keys.VK_SLEEP] = { category = categorys.Keyboard, name = "Sleep", value = keys.VK_SLEEP },
    [keys.VK_NUMPAD0] = { category = categorys.Numpad, name = "Numpad 0", value = keys.VK_NUMPAD0 },
    [keys.VK_NUMPAD1] = { category = categorys.Numpad, name = "Numpad 1", value = keys.VK_NUMPAD1 },
    [keys.VK_NUMPAD2] = { category = categorys.Numpad, name = "Numpad 2", value = keys.VK_NUMPAD2 },
    [keys.VK_NUMPAD3] = { category = categorys.Numpad, name = "Numpad 3", value = keys.VK_NUMPAD3 },
    [keys.VK_NUMPAD4] = { category = categorys.Numpad, name = "Numpad 4", value = keys.VK_NUMPAD4 },
    [keys.VK_NUMPAD5] = { category = categorys.Numpad, name = "Numpad 5", value = keys.VK_NUMPAD5 },
    [keys.VK_NUMPAD6] = { category = categorys.Numpad, name = "Numpad 6", value = keys.VK_NUMPAD6 },
    [keys.VK_NUMPAD7] = { category = categorys.Numpad, name = "Numpad 7", value = keys.VK_NUMPAD7 },
    [keys.VK_NUMPAD8] = { category = categorys.Numpad, name = "Numpad 8", value = keys.VK_NUMPAD8 },
    [keys.VK_NUMPAD9] = { category = categorys.Numpad, name = "Numpad 9", value = keys.VK_NUMPAD9 },
    [keys.VK_MULTIPLY] = { category = categorys.Keyboard, name = "Multiply", value = keys.VK_MULTIPLY },
    [keys.VK_ADD] = { category = categorys.Keyboard, name = "Add", value = keys.VK_ADD },
    [keys.VK_SEPARATOR] = { category = categorys.Keyboard, name = "Separator", value = keys.VK_SEPARATOR },
    [keys.VK_SUBTRACT] = { category = categorys.Keyboard, name = "Subtract", value = keys.VK_SUBTRACT },
    [keys.VK_DECIMAL] = { category = categorys.Keyboard, name = "Decimal", value = keys.VK_DECIMAL },
    [keys.VK_DIVIDE] = { category = categorys.Keyboard, name = "Divide", value = keys.VK_DIVIDE },
    [keys.VK_F1] = { category = categorys.Keyboard, name = "F1", value = keys.VK_F1 },
    [keys.VK_F2] = { category = categorys.Keyboard, name = "F2", value = keys.VK_F2 },
    [keys.VK_F3] = { category = categorys.Keyboard, name = "F3", value = keys.VK_F3 },
    [keys.VK_F4] = { category = categorys.Keyboard, name = "F4", value = keys.VK_F4 },
    [keys.VK_F5] = { category = categorys.Keyboard, name = "F5", value = keys.VK_F5 },
    [keys.VK_F6] = { category = categorys.Keyboard, name = "F6", value = keys.VK_F6 },
    [keys.VK_F7] = { category = categorys.Keyboard, name = "F7", value = keys.VK_F7 },
    [keys.VK_F8] = { category = categorys.Keyboard, name = "F8", value = keys.VK_F8 },
    [keys.VK_F9] = { category = categorys.Keyboard, name = "F9", value = keys.VK_F9 },
    [keys.VK_F10] = { category = categorys.Keyboard, name = "F10", value = keys.VK_F10 },
    [keys.VK_F11] = { category = categorys.Keyboard, name = "F11", value = keys.VK_F11 },
    [keys.VK_F12] = { category = categorys.Keyboard, name = "F12", value = keys.VK_F12 },
    [keys.VK_F13] = { category = categorys.Keyboard, name = "F13", value = keys.VK_F13 },
    [keys.VK_F14] = { category = categorys.Keyboard, name = "F14", value = keys.VK_F14 },
    [keys.VK_F15] = { category = categorys.Keyboard, name = "F15", value = keys.VK_F15 },
    [keys.VK_F16] = { category = categorys.Keyboard, name = "F16", value = keys.VK_F16 },
    [keys.VK_F17] = { category = categorys.Keyboard, name = "F17", value = keys.VK_F17 },
    [keys.VK_F18] = { category = categorys.Keyboard, name = "F18", value = keys.VK_F18 },
    [keys.VK_F19] = { category = categorys.Keyboard, name = "F19", value = keys.VK_F19 },
    [keys.VK_F20] = { category = categorys.Keyboard, name = "F20", value = keys.VK_F20 },
    [keys.VK_F21] = { category = categorys.Keyboard, name = "F21", value = keys.VK_F21 },
    [keys.VK_F22] = { category = categorys.Keyboard, name = "F22", value = keys.VK_F22 },
    [keys.VK_F23] = { category = categorys.Keyboard, name = "F23", value = keys.VK_F23 },
    [keys.VK_F24] = { category = categorys.Keyboard, name = "F24", value = keys.VK_F24 },
    [keys.VK_NUMLOCK] = { category = categorys.Keyboard, name = "Num Lock", value = keys.VK_NUMLOCK },
    [keys.VK_SCROLL] = { category = categorys.Keyboard, name = "Scroll Lock", value = keys.VK_SCROLL },
    [keys.VK_OEM_FJ_JISHO] = { category = categorys.Keyboard, name = "OEM FJ Jisho", value = keys.VK_OEM_FJ_JISHO },
    [keys.VK_OEM_FJ_MASSHOU] = { category = categorys.Keyboard, name = "OEM FJ Masshou", value = keys.VK_OEM_FJ_MASSHOU },
    [keys.VK_OEM_FJ_TOUROKU] = { category = categorys.Keyboard, name = "OEM FJ Touroku", value = keys.VK_OEM_FJ_TOUROKU },
    [keys.VK_OEM_FJ_LOYA] = { category = categorys.Keyboard, name = "OEM FJ Loya", value = keys.VK_OEM_FJ_LOYA },
    [keys.VK_OEM_FJ_ROYA] = { category = categorys.Keyboard, name = "OEM FJ Roya", value = keys.VK_OEM_FJ_ROYA },
    [keys.VK_LSHIFT] = { category = categorys.KeyAccion, name = "Left Shift", value = keys.VK_LSHIFT },
    [keys.VK_RSHIFT] = { category = categorys.KeyAccion, name = "Right Shift", value = keys.VK_RSHIFT },
    [keys.VK_LCONTROL] = { category = categorys.KeyAccion, name = "Left Ctrl", value = keys.VK_LCONTROL },
    [keys.VK_RCONTROL] = { category = categorys.KeyAccion, name = "Right Ctrl", value = keys.VK_RCONTROL },
    [keys.VK_LMENU] = { category = categorys.KeyAccion, name = "Left Alt", value = keys.VK_LMENU },
    [keys.VK_RMENU] = { category = categorys.KeyAccion, name = "Right Alt", value = keys.VK_RMENU },
    [keys.VK_BROWSER_BACK] = { category = categorys.Keyboard, name = "Browser Back", value = keys.VK_BROWSER_BACK },
    [keys.VK_BROWSER_FORWARD] = { category = categorys.Keyboard, name = "Browser Forward", value = keys.VK_BROWSER_FORWARD },
    [keys.VK_BROWSER_REFRESH] = { category = categorys.Keyboard, name = "Browser Refresh", value = keys.VK_BROWSER_REFRESH },
    [keys.VK_BROWSER_STOP] = { category = categorys.Keyboard, name = "Browser Stop", value = keys.VK_BROWSER_STOP },
    [keys.VK_BROWSER_SEARCH] = { category = categorys.Keyboard, name = "Browser Search", value = keys.VK_BROWSER_SEARCH },
    [keys.VK_BROWSER_FAVORITES] = { category = categorys.Keyboard, name = "Browser Favorites", value = keys.VK_BROWSER_FAVORITES },
    [keys.VK_BROWSER_HOME] = { category = categorys.Keyboard, name = "Browser Home", value = keys.VK_BROWSER_HOME },
    [keys.VK_VOLUME_MUTE] = { category = categorys.Keyboard, name = "Volume Mute", value = keys.VK_VOLUME_MUTE },
    [keys.VK_VOLUME_DOWN] = { category = categorys.Keyboard, name = "Volume Down", value = keys.VK_VOLUME_DOWN },
    [keys.VK_VOLUME_UP] = { category = categorys.Keyboard, name = "Volume Up", value = keys.VK_VOLUME_UP },
    [keys.VK_MEDIA_NEXT_TRACK] = { category = categorys.Keyboard, name = "Next Track", value = keys.VK_MEDIA_NEXT_TRACK },
    [keys.VK_MEDIA_PREV_TRACK] = { category = categorys.Keyboard, name = "Previous Track", value = keys.VK_MEDIA_PREV_TRACK },
    [keys.VK_MEDIA_STOP] = { category = categorys.Keyboard, name = "Media Stop", value = keys.VK_MEDIA_STOP },
    [keys.VK_MEDIA_PLAY_PAUSE] = { category = categorys.Keyboard, name = "Play/Pause", value = keys.VK_MEDIA_PLAY_PAUSE },
    [keys.VK_LAUNCH_MAIL] = { category = categorys.Keyboard, name = "Launch Mail", value = keys.VK_LAUNCH_MAIL },
    [keys.VK_LAUNCH_MEDIA_SELECT] = { category = categorys.Keyboard, name = "Launch Media Select", value = keys.VK_LAUNCH_MEDIA_SELECT },
    [keys.VK_LAUNCH_APP1] = { category = categorys.Keyboard, name = "Launch App1", value = keys.VK_LAUNCH_APP1 },
    [keys.VK_LAUNCH_APP2] = { category = categorys.Keyboard, name = "Launch App2", value = keys.VK_LAUNCH_APP2 },
    [keys.VK_OEM_1] = { category = categorys.Keyboard, name = "OEM 1", value = keys.VK_OEM_1 },
    [keys.VK_OEM_PLUS] = { category = categorys.Keyboard, name = "OEM Plus", value = keys.VK_OEM_PLUS },
    [keys.VK_OEM_COMMA] = { category = categorys.Keyboard, name = "OEM Comma", value = keys.VK_OEM_COMMA },
    [keys.VK_OEM_MINUS] = { category = categorys.Keyboard, name = "OEM Minus", value = keys.VK_OEM_MINUS },
    [keys.VK_OEM_PERIOD] = { category = categorys.Keyboard, name = "OEM Period", value = keys.VK_OEM_PERIOD },
    [keys.VK_OEM_2] = { category = categorys.Keyboard, name = "OEM 2", value = keys.VK_OEM_2 },
    [keys.VK_OEM_3] = { category = categorys.Keyboard, name = "OEM 3", value = keys.VK_OEM_3 },
    [keys.VK_ABNT_C1] = { category = categorys.Keyboard, name = "ABNT C1", value = keys.VK_ABNT_C1 },
    [keys.VK_ABNT_C2] = { category = categorys.Keyboard, name = "ABNT C2", value = keys.VK_ABNT_C2 },
    [keys.VK_OEM_4] = { category = categorys.Keyboard, name = "OEM 4", value = keys.VK_OEM_4 },
    [keys.VK_OEM_5] = { category = categorys.Keyboard, name = "OEM 5", value = keys.VK_OEM_5 },
    [keys.VK_OEM_6] = { category = categorys.Keyboard, name = "OEM 6", value = keys.VK_OEM_6 },
    [keys.VK_OEM_7] = { category = categorys.Keyboard, name = "OEM 7", value = keys.VK_OEM_7 },
    [keys.VK_OEM_8] = { category = categorys.Keyboard, name = "OEM 8", value = keys.VK_OEM_8 },
    [keys.VK_OEM_AX] = { category = categorys.Keyboard, name = "OEM AX", value = keys.VK_OEM_AX },
    [keys.VK_OEM_102] = { category = categorys.Keyboard, name = "OEM 102", value = keys.VK_OEM_102 },
    [keys.VK_ICO_HELP] = { category = categorys.Keyboard, name = "ICO Help", value = keys.VK_ICO_HELP },
    [keys.VK_PROCESSKEY] = { category = categorys.Keyboard, name = "Process Key", value = keys.VK_PROCESSKEY },
    [keys.VK_ICO_CLEAR] = { category = categorys.Keyboard, name = "ICO Clear", value = keys.VK_ICO_CLEAR },
    [keys.VK_PACKET] = { category = categorys.Keyboard, name = "Packet", value = keys.VK_PACKET },
    [keys.VK_OEM_RESET] = { category = categorys.Keyboard, name = "OEM Reset", value = keys.VK_OEM_RESET },
    [keys.VK_OEM_JUMP] = { category = categorys.Keyboard, name = "OEM Jump", value = keys.VK_OEM_JUMP },
    [keys.VK_OEM_PA1] = { category = categorys.Keyboard, name = "OEM PA1", value = keys.VK_OEM_PA1 },
    [keys.VK_OEM_PA2] = { category = categorys.Keyboard, name = "OEM PA2", value = keys.VK_OEM_PA2 },
    [keys.VK_OEM_PA3] = { category = categorys.Keyboard, name = "OEM PA3", value = keys.VK_OEM_PA3 },
    [keys.VK_OEM_WSCTRL] = { category = categorys.Keyboard, name = "OEM WSCTRL", value = keys.VK_OEM_WSCTRL },
    [keys.VK_OEM_CUSEL] = { category = categorys.Keyboard, name = "OEM CUSEL", value = keys.VK_OEM_CUSEL },
    [keys.VK_OEM_ATTN] = { category = categorys.Keyboard, name = "OEM Attn", value = keys.VK_OEM_ATTN },
    [keys.VK_OEM_FINISH] = { category = categorys.Keyboard, name = "OEM Finish", value = keys.VK_OEM_FINISH },
    [keys.VK_OEM_COPY] = { category = categorys.Keyboard, name = "OEM Copy", value = keys.VK_OEM_COPY },
    [keys.VK_OEM_AUTO] = { category = categorys.Keyboard, name = "OEM Auto", value = keys.VK_OEM_AUTO },
    [keys.VK_OEM_ENLW] = { category = categorys.Keyboard, name = "OEM Enlw", value = keys.VK_OEM_ENLW },
    [keys.VK_OEM_BACKTAB] = { category = categorys.Keyboard, name = "OEM Backtab", value = keys.VK_OEM_BACKTAB },
    [keys.VK_ATTN] = { category = categorys.Keyboard, name = "Attn", value = keys.VK_ATTN },
    [keys.VK_CRSEL] = { category = categorys.Keyboard, name = "Cr Sel", value = keys.VK_CRSEL },
    [keys.VK_EXSEL] = { category = categorys.Keyboard, name = "Ex Sel", value = keys.VK_EXSEL },
    [keys.VK_EREOF] = { category = categorys.Keyboard, name = "Er Eof", value = keys.VK_EREOF },
    [keys.VK_PLAY] = { category = categorys.Keyboard, name = "Play", value = keys.VK_PLAY },
    [keys.VK_ZOOM] = { category = categorys.Keyboard, name = "Zoom", value = keys.VK_ZOOM },
    [keys.VK_PA1] = { category = categorys.Keyboard, name = "PA1", value = keys.VK_PA1 },
    [keys.VK_OEM_CLEAR] = { category = categorys.Keyboard, name = "OEM Clear", value = keys.VK_OEM_CLEAR },
}


keys.key_names = keyNames
keys.categorys = categorys

function keys.id_to_name(vkey)
	local name = keyNames[vkey]
	if type(name) == 'table' then
		return name[1]
	end
	return name
end

function keys.name_to_id(keyname, case_sensitive)
    if not case_sensitive then
        keyname = string.upper(keyname)
    end
    for id, v in pairs(keys) do
        if type(v) == 'table' then
            for _, name in ipairs(v) do
                local compare_name = (case_sensitive) and name or string.upper(name)
                if compare_name == keyname then
                    return id
                end
            end
        else
            local compare_name = (case_sensitive) and v or string.upper(v)
            if compare_name == keyname then
                return id
            end
        end
    end
end

function keys.key_is_mouse(vkey)
	local key = keyNames[vkey]
    if(key ~= nil) then 
        return (key.category == categorys.Mouse)
    else 
        return nil 
    end
end

function keys.key_is_key_accion(key)
    if(key ~= nil) then 
        return (key.category == categorys.KeyAccion)
    else
        return nil 
    end
end

function keys.get_key_pressed()
    while true do
        wait(0)
        for _, v in pairs(keys) do
            if isKeyJustPressed(v) and not keys.key_is_mouse(v) then
                return keyNames[v] 
            end
        end
    end
end

function keys.parse_array_keys_from_string(ks)
    local listaOrdenada = keys.ordenar(ks)
    local printText = ""

    for _, v in pairs(listaOrdenada) do
        if (printText ~= "") then
            printText = printText .. " + " ..  v.name
        else
            printText = v.name
        end
    end
    
    return printText
end

function keys.ordenar(ks)
    local arr1 = {}
    local arr2 = {}
    for _, k in pairs(ks) do
        if(keys.key_is_key_accion(k)) then 
            table.insert(arr1, k)
        else 
            table.insert(arr2, k) 
        end
    end
    return keys.mergeArrays(arr1, arr2)
end

function keys.mergeArrays(arr1, arr2)
    local result = {}
    
    if(arr1 ~= nil) then
        for _, v in pairs(arr1) do
            table.insert(result, v)
        end
    end

    if(arr2 ~= nil) then
        for _, v in pairs(arr2) do
            table.insert(result, v)
        end
    end
        
    return result
end

function keys.get_hotkey_pressed(keysM)
    while true do
        wait(0)
        if #keysM == 1 then
            if wasKeyPressed(keysM[1].value) and not keys.check_key_pressed_KeyAccion() then
                return true
            end
        else
            
            local allPress = true

            for i, v in pairs(keysM) do
                if i == #keysM then 
                    if not wasKeyPressed(v.value) then allPress = false end
                else
                    if not isKeyDown(v.value) then allPress = false end
                end
            end

            if allPress then return true end
        end
    end
end

function keys.is_key_pressed(keysM)
    if #keysM == 1 then
        if wasKeyPressed(keysM[1].value) and not keys.check_key_pressed_KeyAccion() then
            return true
        end
    else
        
        local allPress = true
    
        for i, v in pairs(keysM) do
            if i == #keysM then 
                if not wasKeyPressed(v.value) then allPress = false end
            else
                if not isKeyDown(v.value) then allPress = false end
            end
        end
    
        if allPress then return true end
    end
    return false
end


function keys.check_key_pressed_KeyAccion()
    return (isKeyDown(keys.VK_LSHIFT) or 
   isKeyDown(keys.VK_RSHIFT) or 
   isKeyDown(keys.VK_LCONTROL) or 
   isKeyDown(keys.VK_RCONTROL) or 
   isKeyDown(keys.VK_LMENU) or
   isKeyDown(keys.VK_RMENU) )
end
return keys