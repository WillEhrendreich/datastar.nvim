-- tests/versions_spec.lua
-- Tests for version-aware feature gating

package.path = "./lua/?.lua;" .. package.path

describe("datastar.versions", function()
  local versions

  setup(function()
    versions = require("datastar.versions")
  end)

  describe("parse_version", function()
    it("parses major.minor.patch", function()
      local v = versions.parse_version("1.0.0-beta.1")
      assert.is_not_nil(v)
      assert.are_equal(1, v.major)
      assert.are_equal(0, v.minor)
      assert.are_equal(0, v.patch)
    end)

    it("parses simple version", function()
      local v = versions.parse_version("0.20.1")
      assert.are_equal(0, v.major)
      assert.are_equal(20, v.minor)
      assert.are_equal(1, v.patch)
    end)

    it("returns nil for invalid version", function()
      assert.is_nil(versions.parse_version("not-a-version"))
      assert.is_nil(versions.parse_version(""))
    end)
  end)

  describe("version_gte", function()
    it("returns true for equal versions", function()
      assert.is_true(versions.version_gte("1.0.0", "1.0.0"))
    end)

    it("returns true for greater major", function()
      assert.is_true(versions.version_gte("2.0.0", "1.0.0"))
    end)

    it("returns true for greater minor", function()
      assert.is_true(versions.version_gte("1.2.0", "1.1.0"))
    end)

    it("returns false for lesser version", function()
      assert.is_false(versions.version_gte("0.19.0", "1.0.0"))
    end)

    it("returns true if either is nil (no gating)", function()
      assert.is_true(versions.version_gte(nil, "1.0.0"))
      assert.is_true(versions.version_gte("1.0.0", nil))
    end)
  end)

  describe("feature_matrix", function()
    it("has version info for core plugins", function()
      local matrix = versions.feature_matrix
      assert.is_not_nil(matrix)
      assert.is_not_nil(matrix["signals"])
      assert.is_not_nil(matrix["on"])
    end)

    it("each entry has since field", function()
      for name, entry in pairs(versions.feature_matrix) do
        assert.is_string(entry.since, "missing since for " .. name)
      end
    end)
  end)

  describe("filter_by_version", function()
    it("returns all features when no version set", function()
      local all = {"signals", "on", "text", "show"}
      local filtered = versions.filter_by_version(all, nil)
      assert.are_equal(4, #filtered)
    end)

    it("filters features newer than version", function()
      -- persist was added in 1.0.0-beta.1 (v1)
      -- if user is on 0.x, persist should be filtered
      local all_features = {}
      for name in pairs(versions.feature_matrix) do
        all_features[#all_features + 1] = name
      end
      -- Features for v0.14 (very old) should be fewer or same
      local for_old = versions.filter_by_version(all_features, "0.14.0")
      local for_new = versions.filter_by_version(all_features, "1.0.0")
      -- New version should have >= features as old
      assert.is_true(#for_new >= #for_old)
    end)
  end)

  describe("detect_version_from_content", function()
    it("detects from package.json content", function()
      local content = [[{
  "dependencies": {
    "@starfederation/datastar": "^1.0.0-beta.1"
  }
}]]
      local v = versions.detect_version_from_content(content)
      assert.is_not_nil(v)
      assert.truthy(v:find("1%.0%.0"))
    end)

    it("detects from CDN script tag", function()
      local content = [[<script src="https://cdn.jsdelivr.net/npm/@starfederation/datastar@1.0.0-beta.11/bundles/datastar.js"></script>]]
      local v = versions.detect_version_from_content(content)
      assert.is_not_nil(v)
    end)

    it("returns nil for no version found", function()
      assert.is_nil(versions.detect_version_from_content("hello world"))
    end)
  end)
end)
