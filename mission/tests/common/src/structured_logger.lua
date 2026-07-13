local StructuredLogger = {}

local function formatValue(value)
  local text = tostring(value)
  text = string.gsub(text, "[\r\n]", " ")
  return text
end

local function formatFields(fields)
  local keys = {}
  local parts = {}

  for key in pairs(fields or {}) do
    keys[#keys + 1] = key
  end

  table.sort(keys)

  for _, key in ipairs(keys) do
    parts[#parts + 1] = tostring(key) .. "=" .. formatValue(fields[key])
  end

  return table.concat(parts, " ")
end

function StructuredLogger.new(prefix)
  local logger = {
    prefix = prefix,
  }

  function logger:write(level, event, fields)
    local suffix = formatFields(fields)
    local line = self.prefix .. " level=" .. level .. " event=" .. event

    if suffix ~= "" then
      line = line .. " " .. suffix
    end

    env.info(line)
  end

  function logger:info(event, fields)
    self:write("INFO", event, fields)
  end

  function logger:error(event, fields)
    self:write("ERROR", event, fields)
  end

  return logger
end

return StructuredLogger
