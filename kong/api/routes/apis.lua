local crud    = require "kong.api.crud_helpers"
local utils   = require "kong.tools.utils"
local reports = require "kong.core.reports"
local workspaces = require "kong.workspaces"
local app_helpers = require "lapis.application"
local singletons = require "kong.singletons"
local Router = require "kong.core.router"
local core_handler = require "kong.core.handler"
local helpers = require "kong.tools.responses"


local function filter(pred, t)
  local res = {}
  for _, v in ipairs(t) do
    if pred(v) then
      res[#res+1] = v
    end
  end
  return res
end


-- returns all routes except the current one
local function all_apis_except(current)
  local old_ws = ngx.ctx.workspace
  ngx.ctx.workspace = { name = "*" }
  local apis = singletons.dao.apis:find_all()
  apis = filter(function(x) return x.id ~= current.id end, apis)
  ngx.ctx.workspace = old_ws
  return apis
end


return {
  ["/apis/"] = {
    before = function(self, dao_factory, helpers)
      local uuid = require("kong.tools.utils").uuid

      local old_ws = ngx.ctx.workspace
      ngx.ctx.workspace = {name = "*"}
      core_handler.build_router(dao_factory, uuid())
      ngx.ctx.workspace = old_ws
    end,

    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.apis)
    end,

    -- XXX: DO NOT add helpers as a third parameter. It collides with
    -- CE and makes merges difficult
    PUT = function(self, dao_factory)
      -- if no id, it acts as POST
      if not self.params.id and workspaces.is_route_colliding(self) then
        local err = "API route collides with an existing API"
        return helpers.send_HTTP_CONFLICT(err)
      end

      local curr_api = singletons.dao.apis:find({id = self.params.id})
      if curr_api then  -- exists, we create an ad-hoc router

        local r = Router.new(all_apis_except(curr_api))
        if workspaces.is_route_colliding(self, r) then
          local err = "API route collides with an existing API"
          return helpers.send_HTTP_CONFLICT(err)
        end
      end

      crud.put(self.params, dao_factory.apis)
    end,

    POST = function(self, dao_factory, helpers)
      if workspaces.is_route_colliding(self) then
        local err = "API route collides with an existing API"
        return helpers.responses.send_HTTP_CONFLICT(err)
      end
      crud.post(self.params, dao_factory.apis)
    end
  },

  ["/apis/:api_name_or_id"] = {
    before = function(self, dao_factory, helpers)
      crud.find_api_by_name_or_id(self, dao_factory, helpers)
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.api)
    end,

    -- XXX: DO NOT add helpers as a third parameter. It collides with
    -- CE and makes merges difficult
    PATCH = function(self, dao_factory)
      local r = Router.new(all_apis_except(self.api))
      -- create temporary router
      if workspaces.is_route_colliding(self, r) then
        local err = "API route collides with an existing API"
        return helpers.send_HTTP_CONFLICT(err)
      end

      crud.patch(self.params, dao_factory.apis, self.api)
    end,

    DELETE = function(self, dao_factory)
      crud.delete(self.api, dao_factory.apis)
    end
  },

  ["/apis/:api_name_or_id/plugins/"] = {
    before = function(self, dao_factory, helpers)
      crud.find_api_by_name_or_id(self, dao_factory, helpers)
      self.params.api_id = self.api.id
    end,

    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.plugins)
    end,

    POST = function(self, dao_factory)
      crud.post(self.params, dao_factory.plugins, function(data)
        local r_data = utils.deep_copy(data)
        r_data.config = nil
        reports.send("api", r_data)
      end)
    end,

    PUT = function(self, dao_factory)
      crud.put(self.params, dao_factory.plugins)
    end
  },

  ["/apis/:api_name_or_id/plugins/:id"] = {
    before = function(self, dao_factory, helpers)
      crud.find_api_by_name_or_id(self, dao_factory, helpers)
      crud.find_plugin_by_filter(self, dao_factory, {
        api_id = self.api.id,
        id     = self.params.id,
      }, helpers)
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.plugin)
    end,

    PATCH = function(self, dao_factory)
      crud.patch(self.params, dao_factory.plugins, self.plugin)
    end,

    DELETE = function(self, dao_factory)
      crud.delete(self.plugin, dao_factory.plugins)
    end
  }
}
