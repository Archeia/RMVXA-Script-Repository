module Enums
  module EffectConstants
    #--------------------------------------------------------------------------
    # ● 定数（使用効果）
    #--------------------------------------------------------------------------
    EFFECT_RECOVER_HP     = 11              # HP 回復
    EFFECT_RECOVER_MP     = 12              # MP 回復
    EFFECT_GAIN_TP        = 13              # TP 増加
    EFFECT_ADD_STATE      = 21              # ステート付加
    EFFECT_REMOVE_STATE   = 22              # ステート解除
    EFFECT_ADD_BUFF       = 31              # 能力強化
    EFFECT_ADD_DEBUFF     = 32              # 能力弱体
    EFFECT_REMOVE_BUFF    = 33              # 能力強化の解除
    EFFECT_REMOVE_DEBUFF  = 34              # 能力弱体の解除
    EFFECT_SPECIAL        = 41              # 特殊効果
    EFFECT_GROW           = 42              # 成長
    EFFECT_LEARN_SKILL    = 43              # スキル習得
    EFFECT_COMMON_EVENT   = 44              # コモンイベント
    #--------------------------------------------------------------------------
    # ● 定数（特殊効果）
    #--------------------------------------------------------------------------
    SPECIAL_EFFECT_ESCAPE = 0               # 逃げる
  end
end
