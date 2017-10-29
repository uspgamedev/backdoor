
local ACTION = {}

function ACTION.unpack(slot)
  local kind, index = slot:match("^(%w+)/(%d+)$")
  kind = kind or slot
  return kind, index
end

ACTION.MOVE           = 'move'
ACTION.INTERACT       = 'interact'
ACTION.USE_SIGNATURE  = 'use_signature'
ACTION.DRAW_NEW_HAND  = 'draw_new_hand'
ACTION.PLAY_CARD      = 'play_card'
ACTION.STASH_CARD     = 'stash_card'
ACTION.CONSUME_CARDS  = 'consume_cards_from_buffer'
ACTION.RECEIVE_PACK   = 'receive_pack'

ACTION.MOVE_COST      = 20

return ACTION

