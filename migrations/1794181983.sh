echo "Fade every window for anyone who already picked Glassy Windows"

# Picking Glassy Windows copies its toggle into the state directory, so a copy
# saved before Glassy faded every window still fades only Nautilus. Theme
# switches no longer give terminals a see-through background of their own, so
# with that copy the next switch left them all but solid. Picking Glassy again
# copies the current toggle and takes the old backgrounds out of the current
# theme, where they would now fade twice.
if [[ -f ${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/window-glassy.lua ]]; then
  omarchy-hyprland-window-transparency glassy
fi
