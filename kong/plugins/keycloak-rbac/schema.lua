local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "keycloak-rbac"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer }, -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    {
      config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          -- a standard defined field (typedef), with some customizations
          {
            rpt_decoded_data_header_name = typedefs.header_name {
              required = true,
              default = "rpt" }
          },
          {
            keycloak_token_endpoint = typedefs.header_name {
              required = true,
              default = "url" }
          },
        },
        entity_checks = {
          -- add some validation rules across fields
          -- the following is silly because it is always true, since they are both required
          { at_least_one_of = { "keycloak_token_endpoint", "rpt_decoded_data_header_name" }, },
          -- We specify that both header-names cannot be the same
          { distinct = { "keycloak_token_endpoint", "rpt_decoded_data_header_name" } },
        },
      },
    },
  },
}

return schema
