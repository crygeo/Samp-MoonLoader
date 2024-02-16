--[[
   Author: THERION
   Description: Some useful color conversion snippets. 
   You can find some of them here: https://www.blast.hk/threads/13380/post-124527
   
   [Functions]
   argb 		split_argb(number color)		splits color number representation to a, r, g, b parts
   number  	join_argb(argb color)			joins color a, r, g, b parts to a number representation
   number  	rgba_to_argb(number color)		converts RGBA color to ARGB
   number  	argb_to_rgb(number color)		converts ARGB color to RGB

   imColor  argb_to_imgui(number color)	converts color to ImColor format
   number  	imgui_to_argb(ImColor color)	converts ImColor to normal color format
   imColor  rgb_to_imgui(number color)	   converts color to ImColor format
   number  	imgui_to_rgb(ImColor color)	converts ImColor to normal color format

   *arbg => return (number)a, (number)r, (number)g, (number)b
   *rgba => return (number)r, (number)g, (number)b, (number)a
   *rgb  => return (number)r, (number)g, (number)b
]]


local imgui = require 'imgui'

local module = {}

module.split_argb = function(hex)
   return
      bit.band(bit.rshift(hex, 24), 255),
      bit.band(bit.rshift(hex, 16), 255), 
      bit.band(bit.rshift(hex, 8), 255), 
      bit.band(hex, 255)
end

module.join_argb = function(a, r, g, b)
   local argb = b
   argb = bit.bor(argb, bit.lshift(g, 8))
   argb = bit.bor(argb, bit.lshift(r, 16))
   argb = bit.bor(argb, bit.lshift(a, 24))
   return argb
end

module.rgba_to_argb = function(rgba)
   local r, g, b, a = hex_to_argb(rgba)
   return module.join_argb(a, r, g, b)
end

module.rgb_to_argb = function(rgb, a)
   return bit.bor(rgb, bit.lshift(a, 24))
end

module.argb_to_rgb = function(argb)
   return bit.band(argb, 0xFFFFFF)
end

module.argb_to_imgui = function(argb)
   local a, r, g, b = module.split_argb(argb)
   return imgui.ImFloat4(imgui.ImColor(r, g, b, a):GetFloat4())
end

module.rgb_to_imgui = function(rgb)
   local _, r, g, b = module.split_argb(rgb)
   return imgui.ImFloat3(r / 255, g / 255, b / 255)
end

module.imgui_to_argb = function(imgui_color)
   return module.join_argb(imgui_color.v[4] * 255, imgui_color.v[1] * 255, imgui_color.v[2] * 255, imgui_color.v[3] * 255)
end

module.imgui_to_rgb = function(imgui_color)
   return module.join_argb(0, imgui_color.v[1] * 255, imgui_color.v[2] * 255, imgui_color.v[3] * 255)
end


return module