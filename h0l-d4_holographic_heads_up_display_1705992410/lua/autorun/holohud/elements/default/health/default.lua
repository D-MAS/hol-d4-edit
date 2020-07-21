--[[------------------------------------------------------------------
  HEALTH AND ARMOUR INDICATORS
  Default layout
]]--------------------------------------------------------------------

if CLIENT then
  -- Namespace
  local HEALTH = HOLOHUD.ELEMENTS.HEALTH;
  local MANA = "mana"
  local EP = "EP"

  -- Panels and highlights
  local PANEL_NAME = HEALTH.PANELS.DEFAULT;
  local DEFAULT, ARMOUR = HEALTH.HIGHLIGHT.HEALTH, HEALTH.HIGHLIGHT.ARMOUR;

  -- local PANEL_VEHICLE = "vehicle"
  -- HOLOHUD:AddFlashPanel(PANEL_VEHICLE);
  -- HOLOHUD:AddHighlight(PANEL_VEHICLE);
  HOLOHUD:AddFlashPanel(MANA);
  HOLOHUD:AddHighlight(MANA);

  HOLOHUD:AddFlashPanel(EP);
  HOLOHUD:AddHighlight(EP);

  -- Parameters
  local HEALTH_PANEL_OFFSET, HEALTH_PANEL_W, HEALTH_PANEL_H = 20, 153, 62;

  --[[
    Draws the armor indicator
    @param {number} x
    @param {number} y
    @param {number} armour
    @param {boolean|nil} invert the suit icon
    @void
  ]]
  local apLerp = 0;
  local function DrawArmour(x, y, armour, invert)
    invert = invert or false;

    -- Set up offset
    local offset = 0;
    if (invert) then offset = 65; x = x + SUIT_W; end

    -- Update lerp
    apLerp = Lerp(FrameTime() * 4, apLerp, armour);

    -- Draw
    HOLOHUD:DrawSilhouette(x, y, HEALTH:GetArmourColour(), apLerp * 0.01, HOLOHUD:GetHighlight(ARMOUR));
    HOLOHUD:DrawNumber(x + 28 - offset, y + 20, armour, HEALTH:GetArmourColour(), nil, HOLOHUD:GetHighlight(ARMOUR), "holohud_small", armour <= 0, TEXT_ALIGN_LEFT);
  end
  
  local HP_LENGTH = 1
  -- local HP_LENGTH_VEHICLE = 1
  local MP_LENGTH = 2
  
  local BAR_OFFSET = 6

  -- local colour = 0
  -- local lerp = 0
  -- local lastDmg = 0;
  -- local blink = 0

  -- local function GetVehicleHealth()
    -- if (not LocalPlayer():InVehicle()) then return -1, 0; end
    -- if (IsValid(LocalPlayer():GetVehicle():GetMoveParent())) then
      -- local ent = LocalPlayer():GetVehicle():GetMoveParent();
      -- if (ent:Health() > ent:GetNWFloat("Health")) then
        -- return ent:Health(), ent:GetMaxHealth();
      -- elseif ent:GetMaxHealth() > 0 then
        -- return ent:GetNWFloat("Health"), ent:GetMaxHealth();
      -- elseif ent.GetHP then
        -- return ent:GetHP(), ent:GetMaxHP();
	  -- else
        -- return ent:GetNWFloat("Health"), ent:GetNWFloat("MaxHealth");
      -- end
    -- else
      -- return LocalPlayer():GetVehicle():Health(), LocalPlayer():GetVehicle():GetMaxHealth();
    -- end
  -- end

  -- local function GetDamageColour()
		-- local ELEMENT_NAME = "health"
		-- local healthPerf = HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "health_perf");
		-- local healthGood = HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "health_good");
		-- local healthWarn = HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "health_warn");
		-- local healthCrit = HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "health_crit");
		-- -- local value = 1 - colour;
		-- local value;
		-- -- if (colour > 1) then
			-- -- value = (1 - (colour - 1));
			-- -- return HOLOHUD:IntersectColour(healthWarn, healthCrit, value);
		-- -- else
			-- -- return HOLOHUD:IntersectColour(healthGood, healthWarn, value);
		-- -- end
		-- -- print(colour, value)
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
  -- end
  
  -- local function DrawVehicleHealth(x, y, width, height, health, maxHealth)
    -- -- Highlight
    -- if (lastDmg ~= health) then
      -- HOLOHUD:TriggerHighlight(PANEL_VEHICLE);
      -- lastDmg = health;
    -- end
	
	-- local hp = health / maxHealth

    -- -- Critical health
    -- if (hp < 0.25 and blink < CurTime()) then
      -- HOLOHUD:TriggerHighlight(PANEL_VEHICLE);
      -- blink = CurTime() + 1.16;
    -- end

    -- -- Set lerp
    -- -- colour = Lerp(FrameTime() * 3, colour, hp*3);
	-- local ELEMENT_NAME = "health"
	-- local usePerf = HOLOHUD.ELEMENTS:GetElementUserConfigParam(ELEMENT_NAME, "health_bool_perf")
	-- local goodHp = HOLOHUD.ELEMENTS:GetElementUserConfigParam(ELEMENT_NAME, "health_thres_good")
	-- local midHp = HOLOHUD.ELEMENTS:GetElementUserConfigParam(ELEMENT_NAME, "health_thres_warn")
	-- local lowHp = HOLOHUD.ELEMENTS:GetElementUserConfigParam(ELEMENT_NAME, "health_thres_crit")

	-- local healthPercent = 100 * health / maxHealth
	-- -- Health colour fade out
	-- if (healthPercent <= lowHp) then
		-- colour = Lerp(FrameTime() * 6, colour, 0);
	-- elseif (healthPercent <= midHp) then
		-- colour = Lerp(FrameTime() * 3, colour, 1);
	-- elseif (healthPercent < goodHp or !usePerf) then
		-- colour = Lerp(FrameTime(), colour, 2);
	-- else
		-- colour = Lerp(FrameTime(), colour, 3);
	-- end


    -- -- Draw
    -- -- if (isDamage) then health = 1 - health; end
    -- lerp = Lerp(FrameTime() * 5, lerp, health);
	-- -- if test then
	  -- -- print(health, maxHealth)
	  -- -- test = false
	-- -- end
    -- HOLOHUD:DrawBar(x + 7, y, width, height, GetDamageColour(), lerp / maxHealth, HOLOHUD:GetHighlight(DEFAULT));
  -- end
  
  local epLerp = 0
  local lastLv = 0
  local lastEp = 0
  local function DrawEP(x, y, lv, ep, nxt)
    if (lastEp ~= ep or lastLv) then
      HOLOHUD:TriggerHighlight(EP);
	  lastLv = lv;
      lastEp = ep;
    end

	-- epLerp = Lerp(FrameTime() * 5, epLerp, (nxt - ep) / nxt);
	epLerp = math.Approach(epLerp, (nxt - ep) / nxt, 0.01);
    HOLOHUD:DrawVerticalBar(x, y, Color(255, 100, 50), epLerp, HOLOHUD:GetHighlight(EP));
  end
  
  local mpLerp = 0
  local lastMp = 0
  local function DrawMana(x, y, w, h, mp, mmp)
    if (lastMp ~= mp) then
      HOLOHUD:TriggerHighlight(MANA);
      lastMp = mp;
    end

	-- mpLerp = Lerp(FrameTime() * 5, mpLerp, mp);
	mpLerp = math.Approach(mpLerp, mp, 1);
    HOLOHUD:DrawBar(x + 7, y, w, h, Color(150, 100, 255), mpLerp / mmp, HOLOHUD:GetHighlight(MANA));
  end

  --[[
    Draws the health and armour indicators -- sandbox version
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number} health
    @param {number} armour
    @param {number} armour number size
    @void
  ]]
  -- local hpLerp = 100;
  local hpLerp = 0;
  -- local function DrawHealth(x, y, w, h, health, armour, armourMargin)
  -- local function DrawHealth(x, y, w, h, health, maxHealth, armour, armourMargin, vhealth, vmaxHealth)
  local function DrawHealth(x, y, w, h, health, maxHealth, armour, armourMargin)
    -- Animate lerp
	-- if health > 0 and health < maxHealth then
		-- hpLerp = Lerp(FrameTime() * 5, hpLerp, (health + 10/3) * (maxHealth + 0) / (maxHealth + 10*2/3));
	-- else
		-- hpLerp = Lerp(FrameTime() * 5, hpLerp, health);
		hpLerp = math.Approach(hpLerp, health, 1);
	-- end
	local offset = 0
	if DLevelling then
		offset = 10
		local ply = LocalPlayer()

		local mp = ply:GetNWInt("MP")
		local mmp = ply:GetNWInt("MaxMP")
		if mmp > 0 then
			DrawMana(x, y + 71, mmp * MP_LENGTH, 18, mp, mmp)
		end

		local lv = ply:GetNWInt("DLevel")
		local ep = ply:GetNWInt("DNext")
		local nxt = DLevelling:NextLevelEP(lv)
		DrawEP(x + 2, y, lv, ep, nxt)
	end

    --  Draw
    DrawArmour(x + 4 + offset, y + 3, armour);
    -- HOLOHUD:DrawNumber(x + w - 7, y + 23, health, HEALTH:GetHealthColour(), nil, HOLOHUD:GetHighlight(DEFAULT), nil, nil, TEXT_ALIGN_RIGHT);
    HOLOHUD:DrawNumber(x + w - 7, y + 23, hpLerp, HEALTH:GetHealthColour(), nil, HOLOHUD:GetHighlight(DEFAULT), nil, nil, TEXT_ALIGN_RIGHT);
    -- HOLOHUD:DrawNumber(x + math.Clamp(w - 7, armourMargin, maxHealth * HP_LENGTH), y + 23, health, HEALTH:GetHealthColour(), nil, HOLOHUD:GetHighlight(DEFAULT), nil, nil, TEXT_ALIGN_RIGHT);
    -- HOLOHUD:DrawBar(x + 7, y + 49, w + 1, 23, HEALTH:GetHealthColour(), hpLerp * 0.01, HOLOHUD:GetHighlight(DEFAULT));
	local offset = 49
	if DLevelling then
		offset = offset + 6
	end
    HOLOHUD:DrawBar(x + 7, y + offset, maxHealth * HP_LENGTH, 23, HEALTH:GetHealthColour(), hpLerp / maxHealth, HOLOHUD:GetHighlight(DEFAULT));
	
	-- end
	-- if vmaxHealth > 0 then
		-- local vw, vh = math.min(vhealth * HP_LENGTH_VEHICLE, 1500), 20
		-- DrawVehicleHealth(x, y + HEALTH_PANEL_H, vw, vh, vhealth, vmaxHealth)
	-- end
  end

  --[[
    Draws the default panel
    @param {number} health
    @param {number} armour
    @param {number} width
    @param {number} height
    @void
  ]]
  -- local test = true
  function HOLOHUD.ELEMENTS.HEALTH:DefaultPanel(health, maxHealth, armour)
    local hpW, apW = HOLOHUD:GetNumberSize(math.max(math.floor(math.log10(health) + 1), 3)), HOLOHUD:GetNumberSize(math.max(math.floor(math.log10(armour) + 1), 3), "holohud_small");
	-- if test then
	  -- print(hpW, apW)
	  -- test = false
	-- end
	local offsetx = 0
	local offsety = 0
	if DLevelling then
		offsetx = offsetx + 10
		offsety = offsety + 6
	end

	local ply = LocalPlayer()
	local mp = ply:GetNWInt("MP")
	local mmp = ply:GetNWInt("MaxMP")
	local mpW = 0
	if mmp > 0 then
		offsety = offsety + 14
		mpW = mmp * MP_LENGTH
	end

	-- local x, y = HEALTH_PANEL_OFFSET, ScrH() - (HEALTH_PANEL_H + HEALTH_PANEL_OFFSET)
	local x, y = HEALTH_PANEL_OFFSET, ScrH() - (HEALTH_PANEL_H + HEALTH_PANEL_OFFSET) - offsety
    local width = math.max(44 + hpW + apW + offsetx, maxHealth * HP_LENGTH, mpW);
	local height = HEALTH_PANEL_H + offsety

	-- local vhealth, vmaxHealth = GetVehicleHealth();
	-- if vmaxHealth > 0 then
		-- y = y - 16
		-- height = height + 16
		-- width = math.max(width, math.min(vmaxHealth * HP_LENGTH_VEHICLE, 1500))
		-- -- DrawVehicleHealth(x, y + HEALTH_PANEL_H, vhealth, vmaxHealth)
	-- end

    -- HOLOHUD:DrawFragment(HEALTH_PANEL_OFFSET, ScrH() - (HEALTH_PANEL_H + HEALTH_PANEL_OFFSET), width, HEALTH_PANEL_H, DrawHealth, PANEL_NAME, health, armour, apW);
	-- HOLOHUD:DrawFragment(x, y, width, height, DrawHealth, PANEL_NAME, health, maxHealth, armour, apW, vhealth, vmaxHealth);
	HOLOHUD:DrawFragment(x, y, width, height, DrawHealth, PANEL_NAME, health, maxHealth, armour, apW);

    return width, height;
  end

end
