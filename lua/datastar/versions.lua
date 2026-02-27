-- datastar.versions — version-aware feature gating
-- Detects Datastar version and filters available features accordingly

local M = {}

--- Parse a semver string into components.
--- @param version_str string e.g. "1.0.0-beta.1"
--- @return table|nil { major, minor, patch }
function M.parse_version(version_str)
  if not version_str or version_str == "" then return nil end
  local major, minor, patch = version_str:match("^(%d+)%.(%d+)%.(%d+)")
  if not major then return nil end
  return {
    major = tonumber(major),
    minor = tonumber(minor),
    patch = tonumber(patch),
  }
end

--- Check if version_a >= version_b (semver comparison).
--- Returns true if either is nil (no gating = allow all).
--- @param a string|nil
--- @param b string|nil
--- @return boolean
function M.version_gte(a, b)
  if not a or not b then return true end
  local va = M.parse_version(a)
  local vb = M.parse_version(b)
  if not va or not vb then return true end

  if va.major ~= vb.major then return va.major > vb.major end
  if va.minor ~= vb.minor then return va.minor > vb.minor end
  return va.patch >= vb.patch
end

--- Feature matrix: which features were introduced at which version.
--- All core plugins are available since the beginning (0.14.x era).
--- Newer features added in 1.0.0-beta series.
M.feature_matrix = {
  -- Core plugins (available since early versions)
  signals = { since = "0.14.0" },
  on = { since = "0.14.0" },
  text = { since = "0.14.0" },
  show = { since = "0.14.0" },
  class = { since = "0.14.0" },
  bind = { since = "0.14.0" },
  model = { since = "0.14.0" },
  ref = { since = "0.14.0" },
  computed = { since = "0.14.0" },
  intersects = { since = "0.14.0" },
  teleport = { since = "0.14.0" },
  ["scroll-into-view"] = { since = "0.14.0" },
  persist = { since = "1.0.0" },
  ["replace-url"] = { since = "1.0.0" },
  indicator = { since = "1.0.0" },
  attributes = { since = "1.0.0" },
  header = { since = "1.0.0" },
  ["custom-validity"] = { since = "1.0.0" },
  ["view-transition"] = { since = "1.0.0" },
  -- Backend-focused plugins
  ["execute-script"] = { since = "0.14.0" },
  ["merge-signals"] = { since = "0.14.0" },
  ["remove-signals"] = { since = "0.14.0" },
  ["merge-fragments"] = { since = "0.14.0" },
  ["remove-fragments"] = { since = "0.14.0" },
}

--- Filter a list of feature names by the detected version.
--- @param features string[] list of feature/plugin names
--- @param version string|nil detected Datastar version (nil = no filtering)
--- @return string[] filtered list
function M.filter_by_version(features, version)
  if not version then return features end

  local result = {}
  for _, name in ipairs(features) do
    local entry = M.feature_matrix[name]
    if not entry or M.version_gte(version, entry.since) then
      result[#result + 1] = name
    end
  end
  return result
end

--- Try to detect Datastar version from file content.
--- Checks package.json dependencies and CDN script tags.
--- @param content string
--- @return string|nil version string
function M.detect_version_from_content(content)
  -- Check package.json style: "@starfederation/datastar": "^1.0.0-beta.1"
  local pkg_ver = content:match('@starfederation/datastar["\']%s*:%s*["\']%^?~?(%d+%.%d+%.%d+)')
  if pkg_ver then return pkg_ver end

  -- Check CDN script tag
  local cdn_ver = content:match('datastar@(%d+%.%d+%.%d+[%w%.%-]*)')
  if cdn_ver then return cdn_ver end

  -- Check importmap style
  local map_ver = content:match('datastar/(%d+%.%d+%.%d+)')
  if map_ver then return map_ver end

  return nil
end

return M
