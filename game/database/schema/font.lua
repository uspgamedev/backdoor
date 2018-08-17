
local filelist = love.filesystem.getDirectoryItems("assets/font")
local files = {}
for _,file in ipairs(filelist) do
  if file:match("^.+%.ttf$") then
    table.insert(files, file)
  end
end

return {
  { id = 'filename', name = "Filename", type = 'enum', options = files }
}

