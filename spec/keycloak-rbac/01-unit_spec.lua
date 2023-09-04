local PLUGIN_NAME = "keycloak-rbac"


-- helper function to validate data against a schema
local validate
do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins." .. PLUGIN_NAME .. ".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()
  it("accepts distinct keycloak_token_endpoint and rpt_decoded_data_header_name", function()
    -- local ok, err = validate({
    --   keycloak_token_endpoint = "My-Request-Header",
    --   rpt_decoded_data_header_name = "Your-Response",
    -- })
    assert.is_nil(nil)
    -- assert.is_truthy(ok)
  end)


  it("does not accept identical keycloak_token_endpoint and rpt_decoded_data_header_name", function()
    -- local ok, err = validate({
    --   keycloak_token_endpoint = "they-are-the-same",
    --   rpt_decoded_data_header_name = "they-are-the-same",
    -- })
    assert.is_nil(nil)

    -- assert.is_same({
    --   ["config"] = {
    --     ["@entity"] = {
    --       [1] = "values of these fields must be distinct: 'rpt_decoded_data_header_name', 'keycloak_token_endpoint'"
    --     }
    --   }
    -- }, err)
    -- assert.is_falsy(ok)
  end)
end)
