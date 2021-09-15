#
# hazel/onyx_register.rb
# vr 1.0.0
#   Hazel/Onyx Component Registry
reg = Hazel::Onyx::ComponentRegistry
reg.init
reg[Hazel::Widget::Button]      = Hazel::Onyx::Sprite_Button
reg[Hazel::Widget::Checkbox]    = Hazel::Onyx::Sprite_Checkbox
reg[Hazel::Widget::RadioButton] = Hazel::Onyx::Sprite_RadioButton
reg[Hazel::Panel] = Hazel::Onyx::Sprite_Panel