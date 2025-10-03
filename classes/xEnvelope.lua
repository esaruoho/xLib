--[[===============================================================================================
xEnvelope
===============================================================================================]]--

--[[--

A virtual representation of an envelope (automation, LFO or otherwise)
.
#

Note: the class is modelled over the Renoise EnvelopeSelectionContent, 

]]

--=================================================================================================

cLib.require(_clibroot.."cPersistence")

---------------------------------------------------------------------------------------------------

class 'xEnvelope' (cPersistence)

xEnvelope.__PERSISTENCE = {
  "points"
}

---------------------------------------------------------------------------------------------------

function xEnvelope:__init()
  TRACE("xEnvelope:__init()")

  -- the point values - array of {
  --  time,     -- point time 
  --  value,    -- point value
  --  playmode, -- interpolation type (renoise.PatternTrackAutomation.PLAYMODE_XX)
  --  } 
  self.points = {}

  -- number, the amount of lines covered if envelope was applied to a pattern
  self.number_of_lines = property(self._get_number_of_lines)

end  

---------------------------------------------------------------------------------------------------
-- check if the automation specifies any points 
-- (shared interface with xEnvelope)
-- @return boolean

function xEnvelope:has_points()
  TRACE("xEnvelope:has_points()")
  
  return (#self.points > 0) 

end 

---------------------------------------------------------------------------------------------------
-- amount of lines covered if envelope was applied to a pattern
-- @return number

function xEnvelope:_get_number_of_lines()
  TRACE("xEnvelope:_get_number_of_lines()")

  if table.is_empty(self.points) then 
    return 0
  end

  local last_time = self.points[#self.points].time 
  return cLib.round_value(last_time-1)

end

---------------------------------------------------------------------------------------------------

function xEnvelope:__tostring()
  return type(self)
    .. ",#points=" .. tostring(#self.points)
end

--=================================================================================================
-- Static methods
--=================================================================================================

---------------------------------------------------------------------------------------------------
-- shift all envelope points by a specified amount
-- @param shift_amount (number) amount to shift (can be negative)
-- @param wrap_mode (boolean, optional) whether to wrap around at boundaries

function xEnvelope.shift(envelope, shift_amount, wrap_mode)
  TRACE("xEnvelope.shift(envelope, shift_amount, wrap_mode)", envelope, shift_amount, wrap_mode)
  
  if not envelope or not envelope.points or (#envelope.points == 0) then
    return
  end
  
  wrap_mode = wrap_mode or false
  
  for i, point in ipairs(envelope.points) do
    local new_time = point.time + shift_amount
    
    if wrap_mode then
      -- wrap around at the envelope length
      local max_time = envelope.number_of_lines
      if new_time < 0 then
        new_time = max_time + new_time
      elseif new_time > max_time then
        new_time = new_time - max_time
      end
    end
    
    point.time = new_time
  end
  
  -- sort points by time after shifting
  table.sort(envelope.points, function(a, b) return a.time < b.time end)
  
end

---------------------------------------------------------------------------------------------------
-- mirror envelope points horizontally (around center point)
-- @param center_time (number, optional) center point for mirroring (defaults to envelope center)

function xEnvelope.mirror(envelope, center_time)
  TRACE("xEnvelope.mirror(envelope, center_time)", envelope, center_time)
  
  if not envelope or not envelope.points or (#envelope.points == 0) then
    return
  end
  
  center_time = center_time or (envelope.number_of_lines / 2)
  
  for i, point in ipairs(envelope.points) do
    -- calculate mirrored time
    local distance_from_center = point.time - center_time
    point.time = center_time - distance_from_center
  end
  
  -- sort points by time after mirroring
  table.sort(envelope.points, function(a, b) return a.time < b.time end)
  
end

---------------------------------------------------------------------------------------------------
-- mirror envelope points vertically (invert values)
-- @param center_value (number, optional) center value for mirroring (defaults to 0.5)

function xEnvelope.mirror_vertical(envelope, center_value)
  TRACE("xEnvelope.mirror_vertical(envelope, center_value)", envelope, center_value)
  
  if not envelope or not envelope.points or (#envelope.points == 0) then
    return
  end
  
  center_value = center_value or 0.5
  
  for i, point in ipairs(envelope.points) do
    -- calculate mirrored value
    local distance_from_center = point.value - center_value
    point.value = center_value - distance_from_center
  end
  
end

---------------------------------------------------------------------------------------------------
-- scale envelope points by a factor
-- @param scale_factor (number) factor to scale by
-- @param scale_time (boolean, optional) whether to scale time values (default: true)
-- @param scale_value (boolean, optional) whether to scale value values (default: false)

function xEnvelope.scale(envelope, scale_factor, scale_time, scale_value)
  TRACE("xEnvelope.scale(envelope, scale_factor, scale_time, scale_value)", envelope, scale_factor, scale_time, scale_value)
  
  if not envelope or not envelope.points or (#envelope.points == 0) then
    return
  end
  
  scale_time = (scale_time ~= false) -- default to true
  scale_value = (scale_value == true) -- default to false
  
  for i, point in ipairs(envelope.points) do
    if scale_time then
      point.time = point.time * scale_factor
    end
    if scale_value then
      point.value = point.value * scale_factor
    end
  end
  
  -- sort points by time after scaling
  if scale_time then
    table.sort(envelope.points, function(a, b) return a.time < b.time end)
  end
  
end

