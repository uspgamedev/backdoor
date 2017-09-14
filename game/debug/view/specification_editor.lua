
local IMGUI = require 'imgui'
local DB    = require 'database'
local INPUT = require 'debug.view.input'

return function(spec, domain_name, title, delete, rename, parent)

  local inputs = {}
  local keys = {}
  for _,key in DB.schemaFor(domain_name) do
    table.insert(keys, key)
    table.insert(inputs, INPUT(key.type, spec, key, parent))
  end

  return title .. " Editor", 2, function(self)
    for i,input in ipairs(inputs) do
      local pop = 0
      local keyid = keys[i].id
      local extended = rawget(spec, 'extends')
      if extended and not rawget(spec, keyid) then
        IMGUI.PushStyleColor("FrameBg", 0.8, 1, 0.9, 0.1)
        pop = 1
      end
      input(self)
      if pop > 0 then
        IMGUI.PopStyleColor(pop)
      elseif extended and keyid ~= 'extends' then
        IMGUI.SameLine()
        if IMGUI.Button("Reset##"..keyid) then
          rawset(spec, keyid, nil)
        end
      end
    end
    IMGUI.Spacing()
    IMGUI.Indent(360)
    if rename and IMGUI.Button("Rename") then
      self:push('name_input', title, rename)
      IMGUI.SameLine()
    end
    if IMGUI.Button("Delete") then
      delete()
      return true
    end
    IMGUI.Unindent(360)
  end

end

