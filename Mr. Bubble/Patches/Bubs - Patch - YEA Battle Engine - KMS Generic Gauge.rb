#==============================================================================
# Compatibility Patch : v1.1 (1/15/12)
# YEA Battle Engine + KMS Generic Gauge
#==============================================================================
# Script by:
# Mr. Bubble
#--------------------------------------------------------------------------
# Place this script below both YEA Battle Engine and Generic Gauge in
# the script edtior.
#==============================================================================

$imported = {} if $imported.nil?
$kms_imported = {} if $kms_imported.nil?

class Window_BattleStatus < Window_Selectable
if $imported["YEA-BattleEngine"] && $kms_imported["GenericGauge"]
#--------------------------------------------------------------------------
# overwrite method: draw_actor_hp
#--------------------------------------------------------------------------
def draw_actor_hp(actor, dx, dy, width = 124)
super(actor, dx, dy, width - 4)
end

#--------------------------------------------------------------------------
# overwrite method: draw_actor_mp
#--------------------------------------------------------------------------
def draw_actor_mp(actor, dx, dy, width = 124)
super(actor, dx, dy, width - 4)
end

#--------------------------------------------------------------------------
# overwrite method: draw_actor_tp
#--------------------------------------------------------------------------
def draw_actor_tp(actor, dx, dy, width = 124)
super(actor, dx, dy, width - 4)
end

end # if $imported
end