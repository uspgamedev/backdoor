
local ACTION = {}

ACTION.IDLE             = 'idle'
ACTION.MOVE             = 'move'
ACTION.INTERACT         = 'interact'
ACTION.USE_SIGNATURE    = 'use_signature'
ACTION.DRAW_NEW_HAND    = 'draw_new_hand'
ACTION.PLAY_CARD        = 'play_card'
ACTION.ACTIVATE_WIDGET  = 'activate_widget'
ACTION.STASH_CARD       = 'stash_card'
ACTION.CONSUME_CARDS    = 'consume_cards_from_buffer'
ACTION.RECEIVE_PACK     = 'receive_pack'

ACTION.EXHAUSTION_UNIT    = 10
ACTION.IDLE_COST          = 1 * ACTION.EXHAUSTION_UNIT
ACTION.PLAY_WIDGET_COST   = 1 * ACTION.EXHAUSTION_UNIT
ACTION.PLAY_UPGRADE_COST  = 1 * ACTION.EXHAUSTION_UNIT
ACTION.MOVE_COST          = 2 * ACTION.EXHAUSTION_UNIT

ACTION.NEW_HAND_COST = 10

return ACTION

