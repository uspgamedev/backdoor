
local IMGUI = require 'imgui'
local DB    = require 'database'
local INPUT = require 'devmode.view.input'

return function(elementspec, group_name, title, delete, rename, parent)

  local inputs = {}
  local fieldschemata = {}
  for _,fieldschema in DB.schemaFor(group_name) do
    table.insert(fieldschemata, fieldschema)
    table.insert(inputs, INPUT(elementspec, fieldschema, parent))
  end

  local function _meta_buttons(gui, spec_meta, id)
    if spec_meta and spec_meta.is_leaf then
      if IMGUI.Button("Save##"..id) then
        DB.save(elementspec)
      end
      IMGUI.SameLine()
    end
    if rename then
      if IMGUI.Button("Rename##"..id) then
        gui:push('name_input', title, rename)
      end
      IMGUI.SameLine()
    end
    if IMGUI.Button("Delete##"..id) then
      delete()
      return true
    end
  end

  return title .. " Editor", 3, function(gui)

    -- meta actions
    local spec_meta = getmetatable(elementspec)
    if _meta_buttons(gui, spec_meta, 1) then return true end
    IMGUI.Spacing()
    IMGUI.Separator()
    IMGUI.Spacing()

    -- editor inputs
    for i,input in ipairs(inputs) do
      local pop = 0
      local fieldschema_id = fieldschemata[i].id
      local extended = rawget(elementspec, 'extends')
      if extended and not rawget(elementspec, fieldschema_id) then
        IMGUI.PushStyleColor("FrameBg", 0.8, 1, 0.9, 0.1)
        pop = 1
      end
      IMGUI.Spacing()
      input(gui)
      if pop > 0 then
        IMGUI.PopStyleColor(pop)
      elseif extended and fieldschema_id ~= 'extends' then
        IMGUI.SameLine()
        if IMGUI.Button("Reset##"..fieldschema_id) then
          rawset(elementspec, fieldschema_id, nil)
        end
      end
    end
    IMGUI.Spacing()
    IMGUI.Separator()
    IMGUI.Spacing()
    if _meta_buttons(gui, spec_meta, 2) then return true end
  end

end

