-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local helpers = require "spec.helpers"
local cjson = require "cjson"

local strategies = helpers.all_strategies ~= nil and helpers.all_strategies or helpers.each_strategy

for _, strategy in strategies() do
describe("Plugin: request-transformer-advanced (API) [#" .. strategy .. "]", function()
  local admin_client
  local db_strategy = strategy ~= "off" and strategy or nil

  lazy_teardown(function()
    if admin_client then
      admin_client:close()
    end

    helpers.stop_kong()
  end)

  describe("POST", function()
    lazy_setup(function()
      helpers.get_db_utils(db_strategy, {
        "plugins",
      })

      assert(helpers.start_kong({
        database   = db_strategy,
        plugins    = "bundled, request-transformer-advanced",
        nginx_conf = "spec/fixtures/custom_nginx.template",
      }))
      admin_client = helpers.admin_client()
    end)

    describe("validate config parameters", function()
      it("remove succeeds without colons", function()
        local res = assert(admin_client:send {
          method = "POST",
          path = "/plugins",
          body = {
            name = "request-transformer-advanced",
            config = {
              remove = {
                headers = {"just_a_key"},
                body = {"just_a_key"},
                querystring = {"just_a_key"},
              },
            },
          },
          headers = {
            ["Content-Type"] = "application/json",
          },
        })
        assert.response(res).has.status(201)
        local body = assert.response(res).has.jsonbody()
        assert.equals("just_a_key", body.config.remove.headers[1])
        assert.equals("just_a_key", body.config.remove.body[1])
        assert.equals("just_a_key", body.config.remove.querystring[1])
      end)
      it("add fails with missing colons for key/value separation", function()
        local res = assert(admin_client:send {
          method = "POST",
          path = "/plugins",
          body = {
            name = "request-transformer-advanced",
            config = {
              add = {
                headers = {"just_a_key"},
              },
            },
          },
          headers = {
            ["Content-Type"] = "application/json",
          },
        })
        local body = assert.response(res).has.status(400)
        local json = cjson.decode(body)
        local msg = "key 'just_a_key' has no value"
        local expected = { config = { add = { headers = { msg } } } }
        assert.same(expected, json["fields"])
      end)
      it("replace fails with missing colons for key/value separation", function()
        local res = assert(admin_client:send {
          method = "POST",
          path = "/plugins",
          body = {
            name = "request-transformer-advanced",
            config = {
              replace = {
                headers = {"just_a_key"},
              },
            },
          },
          headers = {
            ["Content-Type"] = "application/json",
          },
        })
        local body = assert.response(res).has.status(400)
        local json = cjson.decode(body)
        local msg = "key 'just_a_key' has no value"
        local expected = { config = { replace = { headers = { msg } } } }
        assert.same(expected, json["fields"])
      end)
      it("append fails with missing colons for key/value separation", function()
        local res = assert(admin_client:send {
          method = "POST",
          path = "/plugins",
          body = {
            name = "request-transformer-advanced",
            config = {
              append = {
                headers = {"just_a_key"},
              },
            },
          },
          headers = {
            ["Content-Type"] = "application/json",
          },
        })
        local body = assert.response(res).has.status(400)
        local json = cjson.decode(body)
        local msg = "key 'just_a_key' has no value"
        local expected = { config = { append = { headers = { msg } } } }
        assert.same(expected, json["fields"])
      end)
    end)
  end)
end)
end
