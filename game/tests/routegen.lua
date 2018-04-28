
local ROUTE_BUILDER = require 'domain.builders.route'
local IDGenerator = require 'common.idgenerator'


return function()
  local idgen = IDGenerator()
  local route_data = ROUTE_BUILDER.build(idgen.newID(),
                                         {
                                           species = 'hearthborn',
                                           background = 'brawler',
                                         }
  )
    printf("Generated route: %s", route_data.id)
end

