
return function ()
  
  local selected = nil

  local menus = {
    "game_menu", "route_menu", "database_menu",
    game_menu = "Game",
    route_menu = "Current Route",
    database_menu = "Database"
  }

  return "Debug Menu", function(self)
    for _,menu in ipairs(menus) do
      if imgui.Selectable(menus[menu], menu == selected) then
        selected = menu
        self:push(menu)
      end
    end
  end

end

