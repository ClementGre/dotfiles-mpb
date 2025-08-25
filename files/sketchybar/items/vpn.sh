# add parent item on the right side
sketchybar \
  --add item vpn right \
  --set vpn icon="􀉣" \
    icon.font="SF Pro:Medium:14" \
    label.drawing=off \
    click_script="sketchybar --set vpn popup.drawing=toggle" \
    script="sketchybar --set vpn popup.drawing=off" \
    popup.background.color=0xFF000000 \
    popup.background.drawing=on \
    popup.background.corner_radius=5 \
    popup.background.height=120 \
    --subscribe vpn mouse.exited.global

sketchybar \
  --add item vpn_insa popup.vpn \
  --set vpn_insa label="VPN INSA" \
    label.padding_right=8 \
    label.font="SF Pro:Medium:12.5" \
    icon="􀫓" \
    icon.width=29 \
    icon.align=center \
    icon.font="SF Pro:Medium:14" \
    script="$PLUGIN_DIR/vpn_insa.sh" \
  --subscribe vpn_insa mouse.entered

sketchybar \
  --add item vpn_tailscale popup.vpn \
  --set vpn_tailscale label="VPN CLGR" \
    label.padding_right=8 \
    label.font="SF Pro:Medium:12.5" \
    icon="􀪬" \
    icon.width=29 \
    icon.align=center \
    icon.font="SF Pro:Medium:14" \
    script="$PLUGIN_DIR/vpn_tailscale.sh" \
  --subscribe vpn_tailscale mouse.entered

sketchybar \
  --add item vpn_twingate popup.vpn \
  --set vpn_twingate label="VPN SIA" \
    label.padding_right=8 \
    label.font="SF Pro:Medium:12.5" \
    icon="􀮅" \
    icon.width=29 \
    icon.align=center \
    icon.font="SF Pro:Medium:14" \
    script="$PLUGIN_DIR/vpn_twingate.sh" \
  --subscribe vpn_twingate mouse.entered


