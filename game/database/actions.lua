return {

    IDLE = {
      cost = 1,
      params = {},
      values = {},
      effects = {}
    },

    MOVE = {
      cost = 3,
      params = {
        { "direction", {}, "pos" }
      },
      values = {},
      effects = {
        { "move_to", { "par:pos" } }
      }
    },

    SHOOT = {
      cost = 6,
      params = {
        { "choose_target", {5, "BODY"}, "target" },
      },
      values = {
        { "get_attribute", {"ATH"}, "attr" },
        { "add", {"val:attr", 3}, "amount" },
      },
      effects = {
        { "deal_damage", { "par:target", "val:amount" } }
      }
    },
}
