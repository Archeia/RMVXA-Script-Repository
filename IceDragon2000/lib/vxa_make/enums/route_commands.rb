module Enums
  module RouteCommands
    #--------------------------------------------------------------------------
    # ● 定数
    #--------------------------------------------------------------------------
    ROUTE_END               = 0             # 移動ルートの終端
    ROUTE_MOVE_DOWN         = 1             # 下に移動
    ROUTE_MOVE_LEFT         = 2             # 左に移動
    ROUTE_MOVE_RIGHT        = 3             # 右に移動
    ROUTE_MOVE_UP           = 4             # 上に移動
    ROUTE_MOVE_LOWER_L      = 5             # 左下に移動
    ROUTE_MOVE_LOWER_R      = 6             # 右下に移動
    ROUTE_MOVE_UPPER_L      = 7             # 左上に移動
    ROUTE_MOVE_UPPER_R      = 8             # 右上に移動
    ROUTE_MOVE_RANDOM       = 9             # ランダムに移動
    ROUTE_MOVE_TOWARD       = 10            # プレイヤーに近づく
    ROUTE_MOVE_AWAY         = 11            # プレイヤーから遠ざかる
    ROUTE_MOVE_FORWARD      = 12            # 一歩前進
    ROUTE_MOVE_BACKWARD     = 13            # 一歩後退
    ROUTE_JUMP              = 14            # ジャンプ
    ROUTE_WAIT              = 15            # ウェイト
    ROUTE_TURN_DOWN         = 16            # 下を向く
    ROUTE_TURN_LEFT         = 17            # 左を向く
    ROUTE_TURN_RIGHT        = 18            # 右を向く
    ROUTE_TURN_UP           = 19            # 上を向く
    ROUTE_TURN_90D_R        = 20            # 右に 90 度回転
    ROUTE_TURN_90D_L        = 21            # 左に 90 度回転
    ROUTE_TURN_180D         = 22            # 180 度回転
    ROUTE_TURN_90D_R_L      = 23            # 右か左に 90 度回転
    ROUTE_TURN_RANDOM       = 24            # ランダムに方向転換
    ROUTE_TURN_TOWARD       = 25            # プレイヤーの方を向く
    ROUTE_TURN_AWAY         = 26            # プレイヤーの逆を向く
    ROUTE_SWITCH_ON         = 27            # スイッチ ON
    ROUTE_SWITCH_OFF        = 28            # スイッチ OFF
    ROUTE_CHANGE_SPEED      = 29            # 移動速度の変更
    ROUTE_CHANGE_FREQ       = 30            # 移動頻度の変更
    ROUTE_WALK_ANIME_ON     = 31            # 歩行アニメ ON
    ROUTE_WALK_ANIME_OFF    = 32            # 歩行アニメ OFF
    ROUTE_STEP_ANIME_ON     = 33            # 足踏みアニメ ON
    ROUTE_STEP_ANIME_OFF    = 34            # 足踏みアニメ OFF
    ROUTE_DIR_FIX_ON        = 35            # 向き固定 ON
    ROUTE_DIR_FIX_OFF       = 36            # 向き固定 OFF
    ROUTE_THROUGH_ON        = 37            # すり抜け ON
    ROUTE_THROUGH_OFF       = 38            # すり抜け OFF
    ROUTE_TRANSPARENT_ON    = 39            # 透明化 ON
    ROUTE_TRANSPARENT_OFF   = 40            # 透明化 OFF
    ROUTE_CHANGE_GRAPHIC    = 41            # グラフィック変更
    ROUTE_CHANGE_OPACITY    = 42            # 不透明度の変更
    ROUTE_CHANGE_BLENDING   = 43            # 合成方法の変更
    ROUTE_PLAY_SE           = 44            # SE の演奏
    ROUTE_SCRIPT            = 45            # スクリプト
  end
end
