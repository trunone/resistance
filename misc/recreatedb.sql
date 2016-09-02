DROP TABLE IF EXISTS logins;
DROP TABLE IF EXISTS gamelog;
DROP TABLE IF EXISTS gameplayers;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS users;

/* Original schema: */

CREATE TABLE users
(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name VARCHAR(32) NOT NULL UNIQUE,
    passwd TEXT NOT NULL, 
    is_valid BOOLEAN NOT NULL,
    email TEXT NOT NULL,
    create_time TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    validation_code CHAR(16)
);

CREATE TABLE games
( 
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    start_data TEXT NOT NULL, 
    start_time TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP(6),
    spies_win BOOLEAN
);

CREATE TABLE gameplayers
(
    game_id INTEGER NOT NULL REFERENCES games(id) ON DELETE CASCADE, 
    seat SMALLINT NOT NULL, 
    player_id INTEGER NOT NULL REFERENCES users(id),
    is_spy BOOLEAN NOT NULL, 
    CONSTRAINT pk_gameplayers PRIMARY KEY (game_id, seat),
    CONSTRAINT unique_player UNIQUE (player_id, game_id)
);

CREATE TABLE gamelog
(
    game_id INTEGER NOT NULL REFERENCES games(id) ON DELETE CASCADE, 
    id INTEGER NOT NULL,
    player_id INTEGER NOT NULL REFERENCES users(id), 
    action TEXT NOT NULL,
    time TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_gamelog PRIMARY KEY (game_id, id)
);

CREATE TABLE logins
(
    player_id INTEGER NOT NULL REFERENCES users(id),
    time TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip VARCHAR(30) NOT NULL
);

CREATE INDEX idx_logins on logins(player_id, time);

/* CREATE EXTENSION pgcrypto; */

INSERT INTO users(name, passwd, is_valid, email) VALUES ('test1', '', 1, 'test@example.com');
INSERT INTO users(name, passwd, is_valid, email) VALUES ('test2', '', 1, 'test@example.com');
INSERT INTO users(name, passwd, is_valid, email) VALUES ('test3', '', 1, 'test@example.com');
INSERT INTO users(name, passwd, is_valid, email) VALUES ('test4', '', 1, 'test@example.com');
INSERT INTO users(name, passwd, is_valid, email) VALUES ('test5', '', 1, 'test@example.com');

/* Schema change: Games.gameType added */
ALTER TABLE Games ADD game_type SMALLINT NOT NULL DEFAULT 1;
