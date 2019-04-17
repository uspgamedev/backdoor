
local IMGUI = require 'imgui'
local DB    = require 'database'
local INPUT = require 'devmode.view.input'

return function(element_spec, group_name, title, delete, rename, parent)

  local inputs = {}
  local field_specs = {}
  for _,field_spec in DB.schemaFor(group_name) do
    table.insert(field_specs, field_spec)
    table.insert(inputs, INPUT(field_spec.type, element_spec, field_spec,
                               parent))
  end

  return title .. " Editor", 2, function(gui)

    -- meta actions
    local spec_meta = getmetatable(element_spec)
    if spec_meta and spec_meta.is_leaf and IMGUI.Button("Save##1") then
      DB.save(element_spec)
    end
    IMGUI.SameLine()
    if rename and IMGUI.Button("Rename##1") then
      gui:push('name_input', title, rename)
    end
    IMGUI.SameLine()
    if IMGUI.Button("Delete##1") then
      delete()
      return true
    end
    IMGUI.Spacing()
    IMGUI.Separator()
    IMGUI.Spacing()

    -- editor inputs
    for i,input in ipairs(inputs) do
      local pop = 0
      local fieldspec_id = field_specs[i].id
      local extended = rawget(element_spec, 'extends')
      if extended and not rawget(element_spec, fieldspec_id) then
        IMGUI.PushStyleColor("FrameBg", 0.8, 1, 0.9, 0.1)
        pop = 1
      end
      IMGUI.Spacing()
      input(gui)
      if pop > 0 then
        IMGUI.PopStyleColor(pop)
      elseif extended and fieldspec_id ~= 'extends' then
        IMGUI.SameLine()
        if IMGUI.Button("Reset##"..fieldspec_id) then
          rawset(element_spec, fieldspec_id, nil)
        end
      end
    end
    IMGUI.Spacing()
    IMGUI.Separator()
    IMGUI.Spacing()
    if spec_meta and spec_meta.is_leaf and IMGUI.Button("Save##2") then
      DB.save(element_spec)
    end
    IMGUI.SameLine()
    if rename and IMGUI.Button("Rename##2") then
      gui:push('name_input', title, rename)
    end
    IMGUI.SameLine()
    if IMGUI.Button("Delete##2") then
      delete()
      return true
    end
  end

end

