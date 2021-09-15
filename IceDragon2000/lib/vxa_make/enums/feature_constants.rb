module Enums
  module FeatureConstants
    #--------------------------------------------------------------------------
    # ● 定数（特徴）
    #--------------------------------------------------------------------------
    FEATURE_ELEMENT_RATE  = 11              # 属性有効度
    FEATURE_DEBUFF_RATE   = 12              # 弱体有効度
    FEATURE_STATE_RATE    = 13              # ステート有効度
    FEATURE_STATE_RESIST  = 14              # ステート無効化
    FEATURE_PARAM         = 21              # 通常能力値
    FEATURE_XPARAM        = 22              # 追加能力値
    FEATURE_SPARAM        = 23              # 特殊能力値
    FEATURE_ATK_ELEMENT   = 31              # 攻撃時属性
    FEATURE_ATK_STATE     = 32              # 攻撃時ステート
    FEATURE_ATK_SPEED     = 33              # 攻撃速度補正
    FEATURE_ATK_TIMES     = 34              # 攻撃追加回数
    FEATURE_STYPE_ADD     = 41              # スキルタイプ追加
    FEATURE_STYPE_SEAL    = 42              # スキルタイプ封印
    FEATURE_SKILL_ADD     = 43              # スキル追加
    FEATURE_SKILL_SEAL    = 44              # スキル封印
    FEATURE_EQUIP_WTYPE   = 51              # 武器タイプ装備
    FEATURE_EQUIP_ATYPE   = 52              # 防具タイプ装備
    FEATURE_EQUIP_FIX     = 53              # 装備固定
    FEATURE_EQUIP_SEAL    = 54              # 装備封印
    FEATURE_SLOT_TYPE     = 55              # スロットタイプ
    FEATURE_ACTION_PLUS   = 61              # 行動回数追加
    FEATURE_SPECIAL_FLAG  = 62              # 特殊フラグ
    FEATURE_COLLAPSE_TYPE = 63              # 消滅エフェクト
    FEATURE_PARTY_ABILITY = 64              # パーティ能力
    # // >_> Gotta remove these later \/
    #--------------------------------------------------------------------------
    # ● 定数（特殊フラグ）
    #--------------------------------------------------------------------------
    FLAG_ID_AUTO_BATTLE   = 0               # 自動戦闘
    FLAG_ID_GUARD         = 1               # 防御
    FLAG_ID_SUBSTITUTE    = 2               # 身代わり
    FLAG_ID_PRESERVE_TP   = 3               # TP持ち越し
    #--------------------------------------------------------------------------
    # ● 定数（能力強化／弱体アイコンの開始番号）
    #--------------------------------------------------------------------------
    ICON_BUFF_START       = 64              # 強化（16 個）
    ICON_DEBUFF_START     = 80              # 弱体（16 個）
  end
end
