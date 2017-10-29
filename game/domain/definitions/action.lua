
local ACTION = {}

ACTION.IDLE           = 'idle'
ACTION.MOVE           = 'move'
ACTION.INTERACT       = 'interact'
ACTION.USE_SIGNATURE  = 'use_signature'
ACTION.DRAW_NEW_HAND  = 'draw_new_hand'
ACTION.PLAY_CARD      = 'play_card'
ACTION.STASH_CARD     = 'stash_card'
ACTION.CONSUME_CARDS  = 'consume_cards_from_buffer'
ACTION.RECEIVE_PACK   = 'receive_pack'

ACTION.IDLE_TIME      = 20
ACTION.MOVE_TIME      = 20

return ACTION

