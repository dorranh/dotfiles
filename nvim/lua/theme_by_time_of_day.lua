-- Changes NVChad theme based on the time current time of day

local time = os.date "*t"
if time.hour < 8 or time.hour >= 16 then
  require("nvconfig").base46.theme = "everforest"
  require("base46").load_all_highlights()
else
  require("nvconfig").base46.theme = "everforest_light"
  require("base46").load_all_highlights()
end
