---- Base app schema


-- User
CREATE TYPE user_typ AS ENUM ('Sys', 'User');
CREATE TYPE user_sub_typ AS ENUM ('Free', 'Paid');

CREATE TABLE "user" (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  username varchar(128) NOT NULL UNIQUE,
  typ user_typ NOT NULL DEFAULT 'User',
  subscription_status user_sub_typ NOT NULL DEFAULT 'Free',

  -- Auth
  pwd varchar(256),
  pwd_salt uuid NOT NULL DEFAULT gen_random_uuid(),
  token_salt uuid NOT NULL DEFAULT gen_random_uuid(),

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL  
);

-- Agent

CREATE TABLE agent (
  -- PK
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  -- FKs
  owner_id BIGINT NOT NULL,

  -- Properties
  name varchar(256) NOT NULL,
  ai_provider varchar(256) NOT NULL default 'dev', -- For now only support 'dev' provider
  ai_model varchar(256) NOT NULL default 'parrot', -- For now only support 'parrot' model

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL  
);

-- Conv
CREATE TYPE conv_kind AS ENUM ('OwnerOnly', 'MultiUsers');

CREATE TYPE conv_state AS ENUM ('Active', 'Archived');

CREATE TABLE conv (
  -- PK
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  -- FKs
  owner_id BIGINT NOT NULL,
  agent_id BIGINT NOT NULL,

  -- Properties
  title varchar(256),
  kind conv_kind NOT NULL default 'OwnerOnly',
  state conv_state NOT NULL default 'Active',

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL  
);

ALTER TABLE conv ADD CONSTRAINT fk_conv_agent
  FOREIGN KEY (agent_id) REFERENCES "agent"(id)
  ON DELETE CASCADE;


-- Conv Participants
CREATE TABLE conv_user (
  -- PK
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  -- Properties / FKs
  conv_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL, 

  -- Machine User Properties
  auto_respond BOOLEAN NOT NULL DEFAULT false,

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL    
);

-- Conv Messages
CREATE TABLE conv_msg (
  -- PK
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  -- FKs
  conv_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL, -- should be came as cid

  -- Properties
  content varchar(1024) NOT NULL,

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL
);

ALTER TABLE conv_msg ADD CONSTRAINT fk_conv_msg_conv
  FOREIGN KEY (conv_id) REFERENCES "conv"(id)
  ON DELETE CASCADE;

ALTER TABLE conv_user ADD CONSTRAINT fk_conv_user_conv
  FOREIGN KEY (user_id) REFERENCES "user"(id)
  ON DELETE CASCADE;

-- Journal
CREATE TABLE journal
(
    -- PK
    id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

    -- FKs
    user_id BIGINT NOT NULL,

    -- Properties
    title varchar(256) NOT NULL,
    description varchar(1024) NULL,

    -- Timestamps
    cid bigint NOT NULL,
    ctime timestamp with time zone NOT NULL,
    mid bigint NOT NULL,
    mtime timestamp with time zone NOT NULL
);

ALTER TABLE journal ADD CONSTRAINT fk_journal_user
    FOREIGN KEY (user_id) REFERENCES "user"(id)
    ON DELETE CASCADE;

-- Exchange
CREATE TABLE exchange
(
    -- PK
    id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

    -- Properties
    exchange_name varchar(1024) NOT NULL,
    image_id varchar(256) NULL,
    exchange_referral varchar(1024) NOT NULL,
    instruction varchar(1024) NOT NULL,

    -- Timestamps
    cid bigint NOT NULL,
    ctime timestamp with time zone NOT NULL,
    mid bigint NOT NULL,
    mtime timestamp with time zone NOT NULL
);

-- API Key
CREATE TABLE api_key
(
    -- PK
    id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

    -- FKs
    user_id BIGINT NOT NULL,
    exchange_id BIGINT NOT NULL,

    -- TODO add DEXs
    -- Properties
    title varchar(256) NOT NULL,
    api_key_value varchar(256) NOT NULL,
    api_key_secret varchar(256) NULL,
    api_referral boolean NOT NULL DEFAULT false,

    -- Timestamps
    cid bigint NOT NULL,
    ctime timestamp with time zone NOT NULL,
    mid bigint NOT NULL,
    mtime timestamp with time zone NOT NULL
);

ALTER TABLE api_key ADD CONSTRAINT fk_api_key_user
    FOREIGN KEY (user_id) REFERENCES "user"(id)
    ON DELETE CASCADE;
ALTER TABLE api_key ADD CONSTRAINT fk_api_key_exchange
    FOREIGN KEY (user_id) REFERENCES "exchange"(id)
    ON DELETE CASCADE;

-- Tag
CREATE TYPE tag_type AS ENUM ('Entry', 'Exit', 'Management', 'Mistake');

CREATE TABLE tag
(
    -- PK
    id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

    -- FKs
    user_id BIGINT NOT NULL,

    -- Properties
    tag_name varchar(256) NOT NULL,
    tag_type tag_type NOT NULL,
    description varchar(1024) NULL,

    -- Timestamps
    cid bigint NOT NULL,
    ctime timestamp with time zone NOT NULL,
    mid bigint NOT NULL,
    mtime timestamp with time zone NOT NULL
);

ALTER TABLE tag ADD CONSTRAINT fk_tag_user
    FOREIGN KEY (user_id) REFERENCES "user"(id)
    ON DELETE CASCADE;

-- Trade
CREATE TYPE trade_type AS ENUM ('Spot', 'Option', 'Future');
CREATE TYPE direction_type AS ENUM ('Buy', 'Sell');
CREATE TYPE option_type AS ENUM ('Call', 'Put');

CREATE TABLE trade
(
    -- PK
    id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

    -- FKs
    user_id BIGINT NOT NULL,
    journal_id BIGINT NOT NULL,

    -- TODO double check properties
    -- Properties
    trade_type trade_type NOT NULL,
    instrument varchar(50) NOT NULL,
--     setup_id INTEGER NULL,
    entry_time timestamp with time zone NOT NULL,
    exit_time timestamp with time zone NULL,
    direction direction_type NOT NULL,
    option_type option_type NULL,
    multiplier integer NULL,
    entry_price real NOT NULL,
    quantity real NOT NULL,
    target_stop_loss real NULL,
    target_take_profit real NULL,
    exit_price real NULL,
    fees real NULL,
    notes varchar(1024) NULL,
    highest_price real NULL,
    lowest_price real NULL,
    origin_take_profit_hit boolean NULL,

    -- Statistics
    confidence integer NULL,
    entry_rating integer NULL,
    exit_rating integer NULL,
    execution_rating integer NULL,
    management_rating integer NULL,
    net_profit_loss real NULL,
    gross_profit_loss real NULL,
    pnl_percentage real NULL,
    time_in_trade timestamp with time zone NULL,

    -- Timestamps
    cid bigint NOT NULL,
    ctime timestamp with time zone NOT NULL,
    mid bigint NOT NULL,
    mtime timestamp with time zone NOT NULL
);
ALTER TABLE trade ADD CONSTRAINT fk_trade_user
    FOREIGN KEY (user_id) REFERENCES "user"(id)
    ON DELETE CASCADE;

ALTER TABLE trade ADD CONSTRAINT fk_trade_journal
    FOREIGN KEY (journal_id) REFERENCES "journal"(id)
    ON DELETE CASCADE;

-- Trade Tags
CREATE TABLE trade_tag
(
    id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000),
    -- Composite Primary Key
    trade_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    PRIMARY KEY (id, trade_id, tag_id, user_id),

    -- Foreign Keys
--     FOREIGN KEY (trade_id) REFERENCES trade(id)
--         ON DELETE CASCADE,
--     FOREIGN KEY (tag_id) REFERENCES tag(id)
--         ON DELETE CASCADE

    -- Timestamps
    cid bigint NOT NULL,
    ctime timestamp with time zone NOT NULL,
    mid bigint NOT NULL,
    mtime timestamp with time zone NOT NULL
);
ALTER TABLE trade_tag ADD CONSTRAINT fk_trade_tag_trade
    FOREIGN KEY (trade_id) REFERENCES "trade"(id)
    ON DELETE CASCADE;

ALTER TABLE trade_tag ADD CONSTRAINT fk_trade_tag_tag
    FOREIGN KEY (tag_id) REFERENCES "tag"(id)
    ON DELETE CASCADE;

-- Thread
CREATE TABLE thread
(
    -- PK
    id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

    -- FKs
    user_id BIGINT NOT NULL,
    trade_id BIGINT NOT NULL,

    -- TODO images
    -- Properties
    content varchar(1024) NOT NULL,
    image_id varchar(256) NULL,
    image_link varchar(256) NULL,

    -- Timestamps
    cid bigint NOT NULL,
    ctime timestamp with time zone NOT NULL,
    mid bigint NOT NULL,
    mtime timestamp with time zone NOT NULL
);
ALTER TABLE thread ADD CONSTRAINT fk_thread_user
    FOREIGN KEY (user_id) REFERENCES "user"(id)
    ON DELETE CASCADE;

ALTER TABLE thread ADD CONSTRAINT fk_thread_trade
    FOREIGN KEY (trade_id) REFERENCES "trade"(id)
    ON DELETE CASCADE;

-- TODO Setup