
local DB = {}

DB.body = {}

DB.body['hearthborn'] = {
  hp = 12
}

DB.body['slime'] = {
  hp = 8
}

DB.actor = {}

DB.actor['player'] = {
  behavior = 'player'
}

DB.actor['dumb'] = {
  behavior = 'random_walk'
}

return DB

