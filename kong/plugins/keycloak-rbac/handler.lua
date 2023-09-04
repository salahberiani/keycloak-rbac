local httpc = require("resty.http")
local cjson_safe = require "cjson.safe"
local jwt = require "resty.jwt"

local bearer_token =
"Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ6NTI4UTlsTWxtVUk1Y18xTTFVeGdEdGFXRHlHbWNGZ2FSM3FMREsyT3JZIn0.eyJleHAiOjE2OTM4ODI2NjAsImlhdCI6MTY5Mzg0NjY2MCwiYXV0aF90aW1lIjoxNjkzODQ2NjYwLCJqdGkiOiJiYjdjNjc0MS0wYTZmLTQ2OGItYmZmOC1iYjg1NzNjYzM1YWMiLCJpc3MiOiJodHRwOi8vMTAwLjIxLjI0OC4yMjY6ODAwMC9rYy9yZWFsbXMvbWFzdGVyIiwiYXVkIjpbIm1hc3Rlci1yZWFsbSIsImFjY291bnQiXSwic3ViIjoiZjZhMTNmYTQtMmEzZi00NTY4LThhMmItYzM4ODA5NTU1MzI2IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoia29uZyIsIm5vbmNlIjoiZTcxNDViNmUxZWU4YTE5ZjViOTk1MjVhZTk0NWY0ZjUiLCJzZXNzaW9uX3N0YXRlIjoiNjhlN2ExMGEtZjZhMy00MjBkLWJiNDMtODcyZTA3NDgyYTI4IiwiYWNyIjoiMSIsImFsbG93ZWQtb3JpZ2lucyI6WyIqIl0sInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJjcmVhdGUtcmVhbG0iLCJkZWZhdWx0LXJvbGVzLW1hc3RlciIsInRlc3QiLCJvZmZsaW5lX2FjY2VzcyIsInAtc3VwZXItYWRtaW4iLCJhZG1pbiIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsibWFzdGVyLXJlYWxtIjp7InJvbGVzIjpbInZpZXctcmVhbG0iLCJ2aWV3LWlkZW50aXR5LXByb3ZpZGVycyIsIm1hbmFnZS1pZGVudGl0eS1wcm92aWRlcnMiLCJpbXBlcnNvbmF0aW9uIiwiY3JlYXRlLWNsaWVudCIsIm1hbmFnZS11c2VycyIsInF1ZXJ5LXJlYWxtcyIsInZpZXctYXV0aG9yaXphdGlvbiIsInF1ZXJ5LWNsaWVudHMiLCJxdWVyeS11c2VycyIsIm1hbmFnZS1ldmVudHMiLCJtYW5hZ2UtcmVhbG0iLCJ2aWV3LWV2ZW50cyIsInZpZXctdXNlcnMiLCJ2aWV3LWNsaWVudHMiLCJtYW5hZ2UtYXV0aG9yaXphdGlvbiIsIm1hbmFnZS1jbGllbnRzIiwicXVlcnktZ3JvdXBzIl19LCJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwic2lkIjoiNjhlN2ExMGEtZjZhMy00MjBkLWJiNDMtODcyZTA3NDgyYTI4IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6Im5hbWxhIiwiZ2l2ZW5fbmFtZSI6IiIsImZhbWlseV9uYW1lIjoiIiwiZW1haWwiOiJzYWxhaGVkZGluYmVycmlhbmlAZ21haWwuY29tIn0.WAYuKmLCLqvQJIW8q4mybaUXBXYdzuuXRA5vDaK6fEn1icgXiLX1KWC3BR4dXs71T6xahNRRymS0BuYPpHvlc1LRtco5ziXtX0goUImL-JejqfptIY1AwZZn8795c9YqRIkSI6nw6YAQ8xgDTmYFhSAglIAvJB4c61BKKueeEx8nl9emdVDFs1VobqO27J7Upfwr_ISLJ0fKyOD97OC2yX_ajCFMwiCmmnQKRREFVE2Ey7EulpBGUkeRgJXz0DCnoQprwQoMy8s0pbH0TNd_cR2e6gFGO_tvNqc0MsdOcrlxThLdQaxmlE6S7NcFaEId2tcfZOWor7OMwoLAEUS3cg"


local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

local rpttoken

-- runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)
  -- local bearer_token = kong.request.get_header("x-access-token")

  local resty_http = httpc.new()
  local request_path = kong.request.get_path()
  local request_method = kong.request.get_method()

  local resourceScope
  if request_method == "HEAD" then
    resourceScope = "view"
  elseif request_method == "POST" then
    resourceScope = "create"
  end


  kong.log.info(request_path)
  kong.log.info(request_method)
  local _, _, resource = string.find(request_path, "/resource/(%w+)")

  if resource then
    kong.log.info("Extracted resource:", resource)
  else
    kong.log.err("Resource not found in the path.")
    return kong.response.exit(400, [[{"message":"BAD RESOURCE"}]])
  end
  local rpt_post_data = {
    audience = "kong",
    grant_type = "urn:ietf:params:oauth:grant-type:uma-ticket"
  }
  local request_params = {
    method = "POST",
    body = ngx.encode_args(rpt_post_data), -- Encode the POST data as x-www-form-urlencoded
    headers = {
      ["Content-Type"] = "application/x-www-form-urlencoded",
      ["Authorization"] = bearer_token,
    },

  }

  -- local res, err = resty_http:request_uri(plugin_conf.keycloak_token_endpoint,
  --   request_params)
  local res, err = resty_http:request_uri("http://100.21.248.226:8000/kc/realms/master/protocol/openid-connect/token",
    request_params)
  kong.log.info("Access forbidden")
  if not res then
    ngx.log(ngx.ERR, "Failed to get rpt token: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
  end
  local resultjson = cjson_safe.decode(res.body)
  kong.log.debug("access_token ", resultjson["access_token"])
  kong.log.debug("res.body ", res.body)
  local encoded_rpt_token = resultjson["access_token"]
  rpttoken = resultjson["access_token"]
  local rpt_token = jwt:load_jwt(encoded_rpt_token)
  local permissions = rpt_token.payload.authorization.permissions
  kong.log.debug(cjson_safe.encode(rpt_token.payload.authorization.permissions))
  kong.log.info("Access forbidden 0")

  -- Initialize variables to store the result
  local foundResource = nil
  local specificScopeExists = false

  -- Loop through the array to find the object with "rsname" equal to "edge"
  kong.log.info("Access forbidden 1")
  for _, obj in ipairs(permissions) do
    if obj.rsname == resource then
      foundResource = obj
      break -- No need to continue searching if found
    end
  end
  kong.log.info("Access forbidden 2")

  -- If an object with "rsname" equal to "edge" was found, check for a specific scope
  if foundResource then
    for _, scope in ipairs(foundResource.scopes) do
      if scope == resourceScope then
        specificScopeExists = true
        break -- No need to continue searching if found
      end
    end
  end
  kong.log.info("Access forbidden 3")

  -- Check the results
  if foundResource then
    kong.log.info("Object with 'rsname' equal to: ", resource, " found.")
    if specificScopeExists then
      kong.log.info("The specific scope ", resourceScope, " exists in the found object.")
    else
      kong.log.info("The specific scope ", resourceScope, " does not exist in the found object.")
      return kong.response.exit(403, [[{"message":"Access Forbidden"}]])
    end
  else
    kong.log.info("Object with 'rsname' equal to: ", resource, " not found.")
    return kong.response.exit(403, [[{"message":"Access Forbidden"}]])
  end

  kong.log.inspect(plugin_conf) -- check the logs for a pretty-printed config!
  -- kong.service.response.set_header(plugin_conf.rpt_decoded_data_header_name, cjson_safe.encode(rpt_token))
  kong.service.response.set_header("ee", "eeeeee")
  return kong.response.exit(200, [[{"message":"rbac success"}]])
end

function plugin:header_filter(plugin_conf)
  -- your custom code here, for example;
  kong.response.set_header("eeeeeee", rpttoken)
end --]]

return plugin
