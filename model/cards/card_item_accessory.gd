
extends "res://model/cards/card_item.gd"

export(String, MULTILINE) var init_effect_expression = ""
export(String, MULTILINE) var finish_effect_expression = ""

func init_effect(actor):
  var src = "func init_effect(actor):\n" +\
            "\t" + init_effect_expression.replace("\n", "\n\t")

  #print("src=\n\n########\n" + src + "\n#######\n")

  var script = GDScript.new()
  script.set_source_code(src)
  script.reload()

  var obj = Reference.new()
  obj.set_script(script)

  obj.init_effect(actor)


func finish_effect(actor):
  var src = "func finish_effect(actor):\n" +\
            "\t" + finish_effect_expression.replace("\n", "\n\t")

  #print("src=\n\n########\n" + src + "\n#######\n")

  var script = GDScript.new()
  script.set_source_code(src)
  script.reload()

  var obj = Reference.new()
  obj.set_script(script)

  obj.finish_effect(actor)
