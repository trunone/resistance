sqlite3 = require 'sqlite3'

class Database
  constructor: ->
    #@db = new (sqlite3.Database)(':memory:')
    @db = new (sqlite3.Database)('avalon.db')

  initialize: (cb) ->
    cb(null, null)
    return

  # cb(err)
  addUser: (name, password, email, cb) ->
    @db.all "INSERT INTO users(name, passwd, is_valid, email) VALUES (?, ?, 1, ?)", name, password, email,
      (err, rows) ->
        cb(err, rows)

  # cb(err, ??)
  login: (playerId, ip, cb) ->
    @db.all "INSERT INTO logins(player_id, ip) VALUES (?, ?)", playerId, ip,
      (err, rows) ->
        cb(err, null)

  # cb(err, userId)
  getUserId: (name, password, cb) ->
    @db.all "SELECT id, passwd FROM users WHERE name = ? AND is_valid = 1", name,
      (err, rows) ->
        cb(null, rows[0].id)    

  # cb(err, result)
  createGame: (startData, gameType, players, spies, cb) ->
    game_id = null
    @db.all "INSERT INTO games(start_data, game_type) VALUES (?, ?)", startData, gameType
    @db.all "SELECT last_insert_rowid()", (err, rows) ->
      game_id = rows[0].id
    @db.all "BEGIN;\n" +
      (players.map (player, idx) ->
        "INSERT INTO gameplayers(game_id, seat, player_id, is_spy) VALUES (#{game_id}, #{idx}, #{player.id}, #{if player in spies then "true" else "false"});\n").join('') +
      "COMMIT;\n", (err, rows) ->
      cb(null, game_id)

  # Unused?
  getUnfinishedGames: (cb) ->

  # cb(err)
  updateGame: (gameId, id, playerId, action, cb) ->
    @db.all "INSERT INTO gamelog(game_id, id, player_id, action) VALUES (?, ?, ?, ?)", gameId, id, playerId, action,
      (err, rows) ->
        cb(err, null)

  #cb()
  finishGame: (gameId, spiesWin, cb) ->
    @db.all "UPDATE games SET end_time = CURRENT_TIMESTAMP, spies_win = ? WHERE id = ?", spiesWin, gameId,
      (err, rows) ->
        cb(err, null)

  # cb(err, {games, players, gamePlayers})
  getTables: (cb) ->
      async.map [
        "SELECT id, start_time, end_time, spies_win, game_type FROM games WHERE end_time IS NOT NULL ORDER BY start_time"
        "SELECT id, name FROM users"
        "SELECT game_id, player_id, is_spy FROM gameplayers as gp, games as g WHERE gp.game_id = g.id AND g.end_time IS NOT NULL"],
        (item, cb) => @db.all item, cb
        (err, res) =>
          cb null,
            games: res[0]
            players: res[1]
            gamePlayers: res[2]
