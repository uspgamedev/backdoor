
local ACTION = {}

ACTION.IDLE             = 'idle'
ACTION.MOVE             = 'move'
ACTION.INTERACT         = 'interact'
ACTION.USE_SIGNATURE    = 'use_signature'
ACTION.DRAW_NEW_HAND    = 'draw_new_hand'
ACTION.END_FOCUS        = 'end_focus'
ACTION.PLAY_CARD        = 'play_card'
ACTION.DISCARD_CARD     = 'discard_card'
ACTION.ACTIVATE_WIDGET  = 'activate_widget'
ACTION.STASH_CARD       = 'stash_card'
ACTION.CONSUME_CARDS    = 'consume_cards_from_buffer'
ACTION.RECEIVE_PACK     = 'receive_pack'

ACTION.EXHAUSTION_UNIT    = 10
ACTION.MAX_ENERGY         = 10 * ACTION.EXHAUSTION_UNIT

ACTION.IDLE_COST          = 10
ACTION.DISCARD_COST       = 5
ACTION.MOVE_COST          = 10
ACTION.FOCUS_COST         = 10

ACTION.CYCLE_UNIT         = 10

ACTION.MAX_FOCUS          = 3
ACTION.PLAY_WIDGET_FOCUS  = 0

return ACTION
