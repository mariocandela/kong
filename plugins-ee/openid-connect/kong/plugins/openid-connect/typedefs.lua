-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local schema = require "kong.db.schema"


local jwk = schema.define {
  type = "record",
  required = false,
  fields = {
    {
      issuer = {
        type = "string",
        required = false,
      },
    },
    {
      kty = {
        type = "string",
        required = false,
      },
    },
    {
      use = {
        type = "string",
        required = false,
      },
    },
    {
      key_ops = {
        type = "array",
        required = false,
        elements = {
          type = "string",
          required = false,
        }
      },
    },
    {
      alg = {
        type = "string",
        required = false,
      },
    },
    {
      kid = {
        type = "string",
        required = false,
      },
    },
    {
      x5u = {
        type = "string",
        required = false,
      },
    },
    {
      x5c = {
        type = "array",
        required = false,
        elements = {
          type = "string",
          required = false,
        },
      },
    },
    {
      x5t = {
        type = "string",
        required = false,
      },
    },
    {
      ["x5t#S256"] = {
        type = "string",
        required = false,
      },
    },
    {
      k = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
    {
      x = {
        type = "string",
        required = false,
      },
    },
    {
      y = {
        type = "string",
        required = false,
      },
    },
    {
      crv = {
        type = "string",
        required = false,
      },
    },
    {
      n = {
        type = "string",
        required = false,
      },
    },
    {
      e = {
        type = "string",
        required = false,
      },
    },
    {
      d = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
    {
      p = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
    {
      q = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
    {
      dp = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
    {
      dq = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
    {
      qi = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
    {
      oth = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
    {
      r = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
    {
      t = {
        type = "string",
        required = false,
        encrypted = true,
      },
    },
  },
}


return {
  jwk = jwk,
}
