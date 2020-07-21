--[[------------------------------------------------------------------
  SPEED-O-METER
  Displays current vehicle speed
]]--------------------------------------------------------------------

local NET, RPM = "holohud_vehicle_param", "holohud_vehicle_rpm";

if CLIENT then

  -- Parameters
  local PANEL_NAME = "speedometer";
  local KPH_UNIT, MPH_UNIT, UPS_UNIT = "km/h", "MPH", "ups";
  local KPH, MPH = 1.6093, 0.056818181;
  local W, H = 17, 50;
  local SCREEN_OFFSET = 20;

  -- Damage bar
  local BAR_W, BAR_H, BAR_V = 16, 64, 49;
  local BAR_R = BAR_H - BAR_V;
  local BAR_MARGIN = 20;
  -- local GOOD_COLOUR, WARN_COLOUR, CRIT_COLOUR = Color(100, 255, 100), Color(255, 220, 100), Color(255, 90, 80);
  local PERF_COLOUR, GOOD_COLOUR, WARN_COLOUR, CRIT_COLOUR = Color(150, 255, 200, 200), Color(100, 255, 100, 200), Color(255, 220, 100, 200), Color(255, 90, 80, 200);
  local HP_LENGTH = 0.5
  local FP_LENGTH = 2
  local HP_MAX_WIDTH = 1500

  -- Add panel
  HOLOHUD:AddFlashPanel(PANEL_NAME);
  HOLOHUD:AddHighlight(PANEL_NAME);

  -- Add panel
  local FUEL_NAME = "fuel";
  HOLOHUD:AddFlashPanel(FUEL_NAME);
  HOLOHUD:AddHighlight(FUEL_NAME);

  -- Variables
  local lastDmg = 0;
  local colour = 0;
  local blink = 0;
  local lerp = 0;

  --[[
    Returns the real current player velocity
    @return {number} velocity length
  ]]
  local function GetVelocity()
    if (LocalPlayer():InVehicle()) then
      if (IsValid(LocalPlayer():GetVehicle():GetMoveParent())) then
        return LocalPlayer():GetVehicle():GetMoveParent():GetVelocity():Length();
      else
        return LocalPlayer():GetVehicle():GetVelocity():Length();
      end
    else
      return LocalPlayer():GetVelocity():Length();
    end
  end

  --[[
    Return the real health to display
    @return {number} vehicle health
  ]]

  -- local function GetHealth()
    -- if (not LocalPlayer():InVehicle()) then return -1, 0; end
    -- if (IsValid(LocalPlayer():GetVehicle():GetMoveParent())) then
      -- local ent = LocalPlayer():GetVehicle():GetMoveParent();
      -- if (ent:Health() > ent:GetNWFloat("Health")) then
        -- return ent:Health(), ent:GetMaxHealth();
      -- else
        -- return ent:GetNWFloat("Health"), ent:GetMaxHealth();
      -- end
    -- else
      -- return LocalPlayer():GetVehicle():Health(), LocalPlayer():GetVehicle():GetMaxHealth();
    -- end
  -- end

  local function GetVehicleHealth()
    if (not LocalPlayer():InVehicle()) then return -1, 0; end
    if (IsValid(LocalPlayer():GetVehicle():GetMoveParent())) then
      local ent = LocalPlayer():GetVehicle():GetMoveParent();
      if (ent:Health() > ent:GetNWFloat("Health")) then
        return ent:Health(), ent:GetMaxHealth();
      elseif ent:GetMaxHealth() > 0 then
        return ent:GetNWFloat("Health"), ent:GetMaxHealth();
      elseif ent.GetHP then
        return ent:GetHP(), ent:GetMaxHP();
	  else
        return ent:GetNWFloat("Health"), ent:GetNWFloat("MaxHealth");
      end
    else
      return LocalPlayer():GetVehicle():Health(), LocalPlayer():GetVehicle():GetMaxHealth();
    end
  end

  local function GetVehicleFuel()
    local ply = LocalPlayer()
	if not ply:InVehicle() then return -1, 0; end
	local veh = ply:GetVehicle()
	if veh:GetMoveParent() then
		veh = veh:GetMoveParent()
	end
	
	-- if veh.GetFuel then
		-- return veh:GetFuel(), veh:GetMaxFuel()
	-- else
		return veh:GetNWFloat("Fuel", 0), veh:GetNWFloat("MaxFuel", 0)
	-- end
  end

  --[[
    Returns the damage bar's colour
    @param {boolean} health bar as damage bar
    @return {Color} colour
  ]]
  local function GetDamageColour(isDamage)
		-- local healthPerf = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "health_perf");
		-- local healthGood = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "health_good");
		-- local healthWarn = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "health_warn");
		-- local healthCrit = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "health_crit");
		local perfCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "perf_colour");
		local goodCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "good_colour");
		local warnCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "warn_colour");
		local critCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "crit_colour");
		-- local healthPerf = Color(100, 255, 100, 200);
		-- local healthGood = Color( 50, 200,   0, 200);
		-- local healthWarn = Color(200, 175,  50, 200);
		-- local healthCrit = Color(200, 100,  50, 200);
		local value;
		-- if colour <= 1 then
			-- value = colour
			-- return HOLOHUD:IntersectColour(healthWarn, healthCrit, value);
		-- elseif colour <= 2 then
			-- value = colour - 1
			-- return HOLOHUD:IntersectColour(healthGood, healthWarn, value);
		-- else
			-- value = colour - 2
			-- return HOLOHUD:IntersectColour(healthPerf, healthGood, value);
		-- end
		if colour <= 1 then
			value = colour
			-- return HOLOHUD:IntersectColour(healthWarn, healthCrit, value);
			return HOLOHUD:IntersectColour(warnCol, critCol, value);
		elseif colour <= 2 then
			value = colour - 1
			-- return HOLOHUD:IntersectColour(healthGood, healthWarn, value);
			return HOLOHUD:IntersectColour(goodCol, warnCol, value);
		else
			value = colour - 2
			-- return HOLOHUD:IntersectColour(healthPerf, healthGood, value);
			return HOLOHUD:IntersectColour(perfCol, goodCol, value);
		end
  end

  --[[
    Draws the damage bar
    @param {number} x
    @param {number} y
    @param {boolean} health bar as damage bar
    @void
  ]]
  local function DrawDamage(x, y, health, maxHealth, isDamage)
    -- Highlight
    if (lastDmg ~= health) then
      HOLOHUD:TriggerHighlight(PANEL_NAME);
      lastDmg = health;
    end

    -- Critical health
    if (health / maxHealth <= 0.25 and blink < CurTime()) then
      HOLOHUD:TriggerHighlight(PANEL_NAME);
      blink = CurTime() + 1.16;
    end

	local usePerf = HOLOHUD.ELEMENTS:GetElementUserConfigParam(PANEL_NAME, "health_bool_perf")
	local goodHp = HOLOHUD.ELEMENTS:GetElementUserConfigParam(PANEL_NAME, "health_thres_good")
	local midHp = HOLOHUD.ELEMENTS:GetElementUserConfigParam(PANEL_NAME, "health_thres_warn")
	local lowHp = HOLOHUD.ELEMENTS:GetElementUserConfigParam(PANEL_NAME, "health_thres_crit")

	-- local usePerf = true
	-- local goodHp = 100
	-- local midHp = 50
	-- local lowHp = 25

    -- Set lerp
    -- colour = Lerp(FrameTime() * 3, colour, health);

	local healthPercent = 100 * health / maxHealth
	if (healthPercent <= lowHp) then
		colour = Lerp(FrameTime() * 6, colour, 0);
	elseif (healthPercent <= midHp) then
		colour = Lerp(FrameTime() * 3, colour, 1);
	elseif (healthPercent < goodHp or !usePerf) then
		colour = Lerp(FrameTime(), colour, 2);
	else
		colour = Lerp(FrameTime(), colour, 3);
	end

    -- Draw
    if (isDamage) then health = 1 - health; end
    lerp = Lerp(FrameTime() * 5, lerp, health);
    -- HOLOHUD:DrawVerticalBar(x, y, GetDamageColour(isDamage), lerp, HOLOHUD:GetHighlight(PANEL_NAME));
	
	local width = math.min(maxHealth * HP_LENGTH, HP_MAX_WIDTH)
    HOLOHUD:DrawBar(x - width, y, width, 23, GetDamageColour(isDamage), lerp / maxHealth, HOLOHUD:GetHighlight(PANEL_NAME));
  end
  
  local fpLerp = 0
  local lastFp = 0
  local blinkFp = 0
  local function DrawFuel(x, y, fuel, maxFuel)
    -- Highlight
    if (lastFp ~= fuel) then
	  if math.abs(fuel - lastFp) >= 1 then
		HOLOHUD:TriggerHighlight(FUEL_NAME);
	  end
      lastDmg = fuel;
    end

    -- Critical health
    if (fuel / maxFuel <= 0.25 and blinkFp < CurTime()) then
      HOLOHUD:TriggerHighlight(FUEL_NAME);
      blinkFp = CurTime() + 1.16;
    end

	local fpColour = Color(255, 200, 50)
    fpLerp = Lerp(FrameTime() * 5, fpLerp, fuel);
    local width = math.min(maxFuel * FP_LENGTH, HP_MAX_WIDTH)
	
    HOLOHUD:DrawBar(x - width, y, width, 18, fpColour, fpLerp / maxFuel, HOLOHUD:GetHighlight(FUEL_NAME))
  end

  --[[
    Draws the foreground
    @param {boolean} is MPH enabled instead of KPH
    @param {string} unit to display
    @param {boolean} show damage bar inversly
    @param {boolean} force hide damage bar
    @param {Color} text colour
    @param {Color} brackets colour
    @void
  ]]
  local function DrawForeground(x, y, w, h, always, unittype, unit, isDamage, hideBar, colour, bgCol)
    -- Get values
    local offset = 0;
    local hasDamage = false;
    local health, maxHealth = GetVehicleHealth();
	local fuel, maxFuel = GetVehicleFuel();
	-- print(fuel, maxFuel)

    -- Get speed
    local speed = GetVelocity();
    if unittype == 2 then
      speed = speed * MPH;
    elseif unittype == 1 then
      speed = speed * MPH * KPH;
    else -- ups
      speed = speed;
    end

    -- Is vehicle damagable
    if (maxHealth > 0 and not hideBar) then
      -- offset = BAR_MARGIN;
      local panelmul = 1;
      local unitWidth = surface.GetTextSize(unit);
	  -- offset = w - ((W * panelmul) + unitWidth)
	  offset = w - ((W * panelmul) + unitWidth + HOLOHUD:GetNumberSize(3))
      hasDamage = true;
    end
	
    -- Draw speed
    local zeros = "000";
    local unitoffset = 22;
    local bracketoffset = 31;
    if unittype == 3 then
      zeros = "0000";
      unitoffset = 44;
      bracketoffset = 15;
    end;
    -- Draw damage bar
    if (hasDamage and not hideBar) then
      -- DrawDamage(x, y + 1, health/maxHealth, isDamage);
      DrawDamage(x + w + 7, y + BAR_MARGIN + 37, health, maxHealth, isDamage);
    end
	
	if (maxFuel > 0 and not hideBar) then
      DrawFuel(x + w + 7, y + BAR_MARGIN + 53, fuel, maxFuel, isDamage);
	end
	
	-- y = y + offset

    -- HOLOHUD:DrawBracket(x + offset - 3, y - 3, false, bgCol);
    HOLOHUD:DrawBracket(x - 3 + offset, y - 3, false, bgCol);
    -- HOLOHUD:DrawNumber(x + offset + 17, y + (h * 0.5), math.floor(speed), colour, zeros, 0, "holohud_main", not LocalPlayer():InVehicle() and not always);
    HOLOHUD:DrawNumber(x + 17 + offset, y + (H * 0.5), math.floor(speed), colour, zeros, 0, "holohud_main", not LocalPlayer():InVehicle() and not always);
    -- HOLOHUD:DrawText(x + offset + HOLOHUD:GetNumberSize(3) + unitoffset, y + h - 9, unit, "holohud_pickup", colour, nil, nil, TEXT_ALIGN_BOTTOM);
    HOLOHUD:DrawText(x + HOLOHUD:GetNumberSize(3) + unitoffset + offset, y + H - 9, unit, "holohud_pickup", colour, nil, nil, TEXT_ALIGN_BOTTOM);
    HOLOHUD:DrawBracket(x + w - 31, y - 3, true, bgCol);
  end

  --[[
    Animates and draws the panel
    @param {function} config
    @void
  ]]
  local function DrawPanel(config)
    -- Move meter if ammunition panel is active
    local offset = 0;
    if (HOLOHUD:IsPanelActive("ammunition")) then
      local w, h = HOLOHUD.ELEMENTS:GetElementSize("ammunition");
      offset = h + 5;
    end
	
	local ply = LocalPlayer()

    -- Get size
    local unit = KPH_UNIT;
    local unitcommon = 0;
    local panelmul = 2;
    if ply:InVehicle() then
      unitcommon = config("unitveh");
    else
      unitcommon = config("unitfoot");
    end
    if (unitcommon == 2) then unit = MPH_UNIT; end
    if (unitcommon == 3) then
      unit = UPS_UNIT;
      panelmul = 3.4;
    end
    surface.SetFont("holohud_pickup");
    local unitWidth = surface.GetTextSize(unit);
    local w = (W * panelmul) + HOLOHUD:GetNumberSize(3) + unitWidth;
	local h = H
    local health, maxHealth = GetVehicleHealth();
    -- Position
    local x, y = ScrW() - SCREEN_OFFSET - w, ScrH() - SCREEN_OFFSET - H - offset;
    if (config("center")) then
      x = (ScrW() * 0.5) - (w * 0.5);
      y = ScrH() - SCREEN_OFFSET - H;
    end

    if (ply:InVehicle() and maxHealth > 0 and not config("hide_bar")) then
      -- w = w + BAR_MARGIN;
	  -- H = H + BAR_MARGIN
	  h = h + BAR_MARGIN;
	  y = y - BAR_MARGIN;
	  local diff = w
	  w = math.Clamp(HP_LENGTH * maxHealth, w, HP_MAX_WIDTH)
	  diff = w - diff
	  x = x - diff
	  
    end

	local fuel, maxFuel = GetVehicleFuel()
	if (ply:InVehicle() and maxFuel > 0 and not config("hide_bar")) then
	  local bar = 14
	  h = h + bar
	  y = y - bar
	  local diff = w
	  w = math.Clamp(FP_LENGTH * maxFuel, w, HP_MAX_WIDTH)
	  diff = w - diff
	  x = x - diff
	end

    HOLOHUD:SetPanelActive(PANEL_NAME, LocalPlayer():InVehicle() or config("always"));
    HOLOHUD:DrawFragment(x - config("x_offset"), y - config("y_offset"), w, h, DrawForeground, PANEL_NAME, config("always"), unitcommon, unit, config("damage"), config("hide_bar"), config("colour"), config("bg_col"));

    return w, h;
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
    "Speed-o-meter",
    "When in a vehicle, it'll track its speed",
    nil,
    {
      unitveh = { name = "Unit (in vehicle)", value = 1, options = {"km/h", "mph", "ups"} },
      unitfoot = { name = "Unit (on foot)", value = 3, options = {"km/h", "mph", "ups"} },
      damage = { name = "Health bar as damage", desc = "Health meter with count the amount of damage instead of the health left", value = false},
      hide_bar = { name = "Don't show damage bar", value = false },
      center = { name = "Centered", value = false },
      colour = { name = "Foreground colour", value = Color(255, 255, 255) },
      bg_col = { name = "Brackets colour", value = Color(255, 112, 66) },
		health_bool_perf = { name = "Use perfect color", value = true},
		health_thres_good = { name = "Normal colour threshold (%)", value = 100},
		health_thres_warn = { name = "Warning colour threshold (%)", value = 50},
		health_thres_crit = { name = "Critical colour threshold (%)", value = 25},
      perf_colour = { name = "Perf state colour", value = PERF_COLOUR },
      good_colour = { name = "Good state colour", value = GOOD_COLOUR },
      warn_colour = { name = "Warning colour", value = WARN_COLOUR },
      crit_colour = { name = "Critical colour", value = CRIT_COLOUR },
      x_offset = { name = "Horizontal offset", value = 0, minValue = 0, maxValue = ScrW() },
      y_offset = { name = "Vertical offset", value = 0, minValue = 0, maxValue = ScrH() },
      always = { name = "Display on foot", value = false }
    },
    DrawPanel
  );

end
