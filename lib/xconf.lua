local xconf = {}

xconf._COPYRIGHT = "Copyright (C) 2020 Pakulichev & Frankstosh"
xconf._DESCRIPTION = "Configuration Module Based on JSON Parser"
xconf._VERSION = "XConf 1.0.1"

local xconf_class = {}
xconf_class.template = {}

function xconf_class:close()
  self.handle:close()
  self.handle = nil
  return true
end

function xconf_class:set_template(template)
  if type(template) ~= 'table' then
    return false
  end

  self.template = template
  return true
end

local function integrate_tables(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == 'table' then
      if type(t1[k]) ~= 'table' then
        t1[k] = {}
      end
      integrate_tables(t1[k], t2[k])
    else
      if not t1[k] then
        t1[k] = v
      end
    end
  end
end

function xconf_class:get(table_pointer)
  if not self.handle then
    return false
  end

  local content = self.content
  if type(content) ~= 'string' then
    return false
  end

  local result, t = pcall(decodeJson, content)
  if not result or type(t) ~= 'table' then
    return false
  end

  integrate_tables(t, self.template)
  self.last_get = t


  if table_pointer then
    table_pointer = t
    return type(table_pointer) == 'table'
  end

  return t
end

function xconf_class:set(t)
  if not self.handle then
    return false
  end

  t = t or self.last_get
  if type(t) ~= 'table' then
    return false
  end

  integrate_tables(t, self.template)
  local result, content = pcall(encodeJson, t, true)
  if not result or type(content) ~= 'string' then
    return false
  end

  self.handle:close()

  self.handle = io.open(self.filename, "w+")
  self.handle:write(content); self.handle:close()

  self.handle = io.open(self.filename, "r+")
  self.content = content
end

function xconf.new(filename)
  if type(filename) ~= 'string' then
    return false
  end

  if not doesFileExist(filename) then
    local file = io.open(filename, "w+")
    if not file then
      return false
    end
  end

  local file = io.open(filename, "r+")
  if not file then
    return false
  end

  local new_object = {}
  setmetatable(new_object, {
    __index = xconf_class,
    __tostring = "XConf Handle"
  })

  new_object.filename = filename
  new_object.handle = file
  new_object.content = file:read("*a")

  return new_object
end

return xconf