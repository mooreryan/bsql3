import better_sqlite3 as sql
import gleam/dynamic/decode.{type Decoder}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

type User {
  User(id: Int, name: String, age: Int)
}

fn user_decoder() -> Decoder(User) {
  use id <- decode.field("id", decode.int)
  use name <- decode.field("name", decode.string)
  use age <- decode.field("age", decode.int)
  decode.success(User(id:, name:, age:))
}

fn bad_user_decoder() -> Decoder(User) {
  use id <- decode.field("x-id", decode.int)
  use name <- decode.field("x-name", decode.string)
  use age <- decode.field("x-age", decode.int)
  decode.success(User(id:, name:, age:))
}

pub fn basic_usage_test() {
  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(Nil) =
    sql.exec(
      db,
      "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
    )

  let assert Ok(insert_statement) =
    sql.prepare(db, "INSERT INTO users (name, age) VALUES (?, ?)")

  let assert Ok(Nil) =
    sql.run(insert_statement, [sql.coerce_string("Alice"), sql.coerce_int(30)])

  let assert Ok(all_users_statement) = sql.prepare(db, "SELECT * FROM users")

  let assert Ok([user]) = sql.all(all_users_statement, [], user_decoder())

  let assert Ok(Nil) = sql.close(db)

  assert user.name == "Alice"
  assert user.age == 30
}

/// Decoders that don't work properly give you a useful error so that you can
/// figure out what went wrong.
///
pub fn bad_decoder_test() {
  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(Nil) =
    sql.exec(
      db,
      "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
    )

  let assert Ok(insert_statement) =
    sql.prepare(db, "INSERT INTO users (name, age) VALUES (?, ?)")

  let assert Ok(Nil) =
    sql.run(insert_statement, [sql.coerce_string("Alice"), sql.coerce_int(30)])

  let assert Ok(all_users_statement) = sql.prepare(db, "SELECT * FROM users")

  let assert Error(sql.DecodeError(_)) =
    sql.all(all_users_statement, [], bad_user_decoder())

  let assert Ok(Nil) = sql.close(db)
}

/// You can't run more stuff on a db after it has been closed.
///
pub fn db_close_test() {
  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(Nil) = sql.close(db)
  let assert Error(sql.JsError(_, _, _)) = sql.exec(db, "SELECT 1")
}

/// Pragmas work, like setting foreign key constraints.
///
pub fn pragma_foreign_key_test() {
  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(Nil) = sql.pragma(db, "foreign_keys = ON")
  let assert Ok(Nil) =
    sql.exec(
      db,
      "CREATE TABLE users (id INTEGER PRIMARY KEY);"
        <> "CREATE TABLE posts (id INTEGER PRIMARY KEY, user_id INTEGER, FOREIGN KEY (user_id) REFERENCES users(id));",
    )
  let assert Error(sql.JsError(
    name: "SqliteError",
    code: "SQLITE_CONSTRAINT_FOREIGNKEY",
    message: "FOREIGN KEY constraint failed",
  )) = sql.exec(db, "INSERT INTO posts (user_id) VALUES (1234)")

  // Turn the foreign keys off and we can insert
  let assert Ok(Nil) = sql.pragma(db, "foreign_keys = OFF")

  let assert Ok(Nil) = sql.exec(db, "INSERT INTO posts (user_id) VALUES (1234)")

  let assert Ok(Nil) = sql.close(db)
}
