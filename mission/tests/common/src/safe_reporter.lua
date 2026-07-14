local SafeReporter = {}

local function sanitize(value)
  local ok, text = pcall(tostring, value)
  if not ok then
    text = "unprintable error"
  end
  text = string.gsub(text, "[%c]", " ")
  return text
end

function SafeReporter.report(event, outcome, detail, prefix)
  if type(env) ~= "table" or type(env.info) ~= "function" then
    return false
  end

  local reportPrefix = prefix or "[OMW][TM01A]"
  local line = sanitize(reportPrefix) .. " level=ERROR event=" .. sanitize(event)
    .. " outcome=" .. sanitize(outcome)
    .. " error=" .. sanitize(detail)
  env.info(line)
  return true
end

return SafeReporter