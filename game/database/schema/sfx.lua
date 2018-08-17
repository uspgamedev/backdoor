
local filelist = love.filesystem.getDirectoryItems("assets/sfx")
local files = {}
for _,file in ipairs(filelist) do
  if file:match("^.+%.wav$") then
    table.insert(files, file)
  end
end

return {
  { id = 'filename', name = "Filename", type = 'enum', options = files }
}
