
local ACTION = {}

ACTION.IDLE             = 'idle'
ACTION.MOVE             = 'move'
ACTION.INTERACT         = 'interact'
ACTION.USE_SIGNATURE    = 'use_signature'
ACTION.PLAY_CARD        = 'play_card'
ACTION.DISCARD_CARD     = 'discard_card'
ACTION.ACTIVATE_WIDGET  = 'activate_widget'
ACTION.STASH_CARD       = 'stash_card'
ACTION.CONSUME_CARDS    = 'consume_cards_from_buffer'
ACTION.RECEIVE_PACK     = 'receive_pack'

ACTION.EXHAUSTION_UNIT    = 10
ACTION.MAX_ENERGY         = 10 * ACTION.EXHAUSTION_UNIT

ACTION.FULL_EXHAUSTION    = 10
ACTION.HALF_EXHAUSTION    = 5

ACTION.CYCLE_UNIT         = 10

ACTION.MAX_FOCUS          = 5
ACTION.FOCUS_PER_TURN     = 1
ACTION.PLAY_WIDGET_FOCUS  = 0

return ACTION
