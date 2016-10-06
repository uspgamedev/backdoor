extends Control

const CardSprite = preload("res://components/ui/card_sprite.gd")
const CardItem = preload("res://components/ui/card_list_item.tscn")

signal close_popup

func clear():
  for child in self.get_node("FocusDialog/Panel/FocusList").get_children():
    child.free()

func display(focuses):
  self.clear()

  self.get_node("FocusDialog").show_modal(true)

  self.get_node("FocusDialog").enable()

  for upg in focuses:
    var item = CardItem.instance()
    item.get_node("CardHook/Card").free()

    var card_sprite = CardSprite.create(upg)
    card_sprite.set_name("Card")

    item.get_node("CardHook").add_child(card_sprite)
    item.get_node("CardName").set_text(card_sprite.get_node("Name").get_text())
    card_sprite.get_node("Name").free()

    self.get_node("FocusDialog/Panel/FocusList").add_child(item)


func is_hidden():
  return self.get_node("FocusDialog").is_hidden()

func hide():
  emit_signal("close_popup")
  self.get_node("FocusDialog").hide()
