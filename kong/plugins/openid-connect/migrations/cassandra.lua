return {
  {
    name = "2017-06-08-000000_init_oic",
    up = [[
      CREATE TABLE IF NOT EXISTS oic_issuers (
        id            uuid,
        issuer        text,
        configuration text,
        keys          text,
        created_at    timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON oic_issuers (issuer);

      CREATE TABLE IF NOT EXISTS oic_signout (
        id            uuid,
        jti           text,
        iss           text,
        sid           text,
        sub           text,
        aud           text,
        created_at    timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON oic_signout (iss);
      CREATE INDEX IF NOT EXISTS ON oic_signout (sid);
      CREATE INDEX IF NOT EXISTS ON oic_signout (sub);
      CREATE INDEX IF NOT EXISTS ON oic_signout (jti);

      CREATE TABLE IF NOT EXISTS oic_session (
        id            uuid,
        sid           text,
        exp           int,
        data          text,
        created_at    timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON oic_session (sid);
      CREATE INDEX IF NOT EXISTS ON oic_session (exp);

      CREATE TABLE IF NOT EXISTS oic_revoked (
        id            uuid,
        hash          text,
        exp           int,
        created_at    timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON oic_revoked (hash);
      CREATE INDEX IF NOT EXISTS ON oic_revoked (exp);
    ]],
    down = [[
      DROP TABLE oic_issuers;
      DROP TABLE oic_signout;
      DROP TABLE oic_session;
      DROP TABLE oic_revoked;
    ]]
  },
}
