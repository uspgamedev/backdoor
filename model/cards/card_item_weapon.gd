
extends "res://model/cards/card_item.gd"

export(String) var damage_expression = "$2d6"


func calc_dice_value(dice):
  var regex = RegEx.new()
  regex.compile("\\$(\\d{1,2})d(\\d{1,2})")
  regex.find(dice)
  var dcount = regex.get_capture(1).to_int()
  var dfaces = regex.get_capture(2).to_int()
  return "dice(" + var2str(dcount) + ", " + var2str(dfaces) + ")"

func get_damage_expression(dice_str):
  var regex = RegEx.new()
  regex.compile("(\\$[\\d]{1,2}d[\\d]{1,2})")
  var found = regex.find(dice_str)
  while found >= 0:
    var dice_expr = regex.get_captures()[0]
    var dice_func = calc_dice_value(dice_expr)
    dice_str = dice_str.replace(dice_expr, dice_func)
    found = regex.find(dice_str)
  return dice_str

func calculate_damage(player):
  var exp_aux = damage_expression.replace("$ATH", var2str(player.get_athletics()))\
                    .replace("$ARC", var2str(player.get_arcana()))\
                    .replace("$TEC", var2str(player.get_tech()))
  var damage_exp = get_damage_expression(exp_aux)
  var src = "extends \"res://components/util/damage_formula.gd\"\n\n" +\
            "func eval():\n" +\
            "\treturn " + damage_exp

  #print("src=\n\n########\n" + src + "\n#######\n")

  var script = GDScript.new()
  script.set_source_code(src)
  script.reload()

  var obj = Reference.new()
  obj.set_script(script)

  consume_item()

  return obj.eval()
