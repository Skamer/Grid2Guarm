-- Add the Guarm volatile debuff status, created by Skamer.
-- Thank to grid authors to have done this wonderful addon.
local GuarmVolatile = Grid2.statusPrototype:new("guarm-volatile")

local Grid2 = Grid2

-- Wow APi
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local GetSpellDescription = GetSpellDescription
local GetTalentInfo = GetTalentInfo
local GetSpecialization = GetSpecialization
local UnitGUID = UnitGUID

-- data
local RED_VOLATILE_NAME = GetSpellInfo(228744) -- 228744
local BLUE_VOLATILE_NAME = GetSpellInfo(228810) -- 208065 -- 228810
local PURPLE_VOLATILE_NAME = GetSpellInfo(228819) -- 228819

local RED_AURA_NAME = GetSpellInfo(228758) -- 228758
local BLUE_AURA_NAME = GetSpellInfo(228768)
local PURPLE_AURA_NAME = GetSpellInfo(228769) -- 228769

-- cache
local AuraPlayers = {}
local VolatilePlayers = {}

--
local playerGUID = nil

GuarmVolatile.UpdateAllUnits = Grid2.statusLibrary.UpdateAllUnits

function GuarmVolatile:OnEnable()
  playerGUID = UnitGUID("player")

  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function GuarmVolatile:OnDisable()
  self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function GuarmVolatile:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, message, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, destFlags2, ...)
  if message == "SPELL_AURA_APPLIED" or message  == "SPELL_AURA_REFRESH" or msg == "SPELL_AURA_APPLIED_DOSE" then
      local spellID, spellName = ...

      if spellName == BLUE_VOLATILE_NAME then
        VolatilePlayers[destGUID] = BLUE_VOLATILE_NAME
      elseif spellName == RED_VOLATILE_NAME then
        VolatilePlayers[destGUID] = RED_VOLATILE_NAME
      elseif spellName == PURPLE_VOLATILE_NAME then
        VolatilePlayers[destGUID] = PURPLE_VOLATILE_NAME
      elseif spellName == BLUE_AURA_NAME then
        AuraPlayers[destGUID] = BLUE_AURA_NAME
      elseif spellName == RED_AURA_NAME then
        AuraPlayers[destGUID] = RED_AURA_NAME
      elseif spellName == PURPLE_AURA_NAME then
        AuraPlayers[destGUID] = PURPLE_AURA_NAME
      end
      self:UpdateAllUnits()
  elseif message == "SPELL_AURA_REMOVED" or message == "SPELL_AURA_REMOVED_DOSE" then
    local spellID, spellName = ...
    if spellName == BLUE_VOLATILE_NAME then
      VolatilePlayers[destGUID] = nil
    elseif spellName == RED_VOLATILE_NAME then
      VolatilePlayers[destGUID] = nil
    elseif spellName == PURPLE_VOLATILE_NAME then
      VolatilePlayers[destGUID] = nil
    elseif spellName == BLUE_AURA_NAME then
      AuraPlayers[destGUID] = nil
    elseif spellName == RED_AURA_NAME then
      AuraPlayers[destGUID] = nil
    elseif spellName == PURPLE_AURA_NAME then
      AuraPlayers[destGUID] = nil
    end
    self:UpdateAllUnits()
  end

end

function GuarmVolatile:IsActive(unit)
  local guid = UnitGUID(unit)

  local volatileName = VolatilePlayers[guid]

  if not volatileName then return false end

  local auraName = AuraPlayers[guid]
  if volatileName == RED_VOLATILE_NAME and not (auraName == RED_AURA_NAME) then
    return true
  elseif volatileName == BLUE_VOLATILE_NAME and not (auraName == BLUE_AURA_NAME) then
    return true
  elseif volatileName == PURPLE_VOLATILE_NAME and not (auraName == PURPLE_AURA_NAME) then
    return true
  end

  return false
end

function GuarmVolatile:GetExpirationTime(unit)
  local guid = UnitGUID(unit)
  local volatileName = VolatilePlayers[guid]

  local _, _, _, _, _, _, expirationTime = UnitDebuff(unit, volatileName)
  return expirationTime
end

function GuarmVolatile:GetDuration(unit)
  local guid = UnitGUID(unit)
  local volatileName = VolatilePlayers[guid]

  local _, _, _, _, _, duration = UnitDebuff(unit, volatileName)
  return duration
end

function GuarmVolatile:GetIcon(unit)
  local guid = UnitGUID(unit)
  local volatileName = VolatilePlayers[guid]
  local texture

  if volatileName == RED_VOLATILE_NAME then
    texture = GetSpellTexture(228744)
  elseif volatileName == BLUE_VOLATILE_NAME then
    texture = GetSpellTexture(228810)
  elseif volatileName == PURPLE_VOLATILE_NAME then
    texture = GetSpellTexture(228819)
  end

  return texture
end

function GuarmVolatile:GetColor()
  local color = self.dbx.color1
  return color.r, color.g, color.b, color.a
end

local function CreateStatusGuarmVolatile(baseKey, dbx)
	Grid2:RegisterStatus(GuarmVolatile, {"color", "icon"}, baseKey, dbx)
	return GuarmVolatile
end

Grid2.setupFunc["guarm-volatile"] = CreateStatusGuarmVolatile

Grid2:DbSetStatusDefaultValue("guarm-volatile", {type = "guarm-volatile",  color1= {r=0,g=1,b=0,a=1} } )
-- Hook to set the option properties
local PrevLoadOptions = Grid2.LoadOptions
function Grid2:LoadOptions()
  PrevLoadOptions(self)
  Grid2Options:RegisterStatusOptions("guarm-volatile", "debuff", nil, {title="Guarm Volatile", titleIcon = GetSpellTexture(228744), titleDesc="Guarm Volatile Options (Mythic Mode)"})
end
