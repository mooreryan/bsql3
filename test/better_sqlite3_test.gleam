import better_sqlite3 as sql
import gleam/dynamic/decode.{type Decoder}
import gleam/result
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
    sql.run(insert_statement, [sql.text("Alice"), sql.int(30)])

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
    sql.run(insert_statement, [sql.text("Alice"), sql.int(30)])

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

pub fn x_test() {
  // let assert Ok([1234]) = {
  //   use db <- sql.with_database(":memory:")
  //   use stmt <- result.try(sql.prepare(db, "select ?"))
  //   sql.all(stmt, [sql.int(1234)], decode.int)
  // }
  //
  // let assert Ok([1234]) = {
  //   use db <- sql.with_database(":memory:")
  //   use stmt <- result.try(sql.prepare(db, "select 1234"))
  //   sql.all(stmt, [], decode.field(0, decode.int, decode.success))
  // }

  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(stmt) = sql.prepare(db, "select 1234")

  let assert Ok([1234]) =
    // If you're reading this code expecting the decoder to look like those from
    // the sqlight library, don't be alarmed that they are different. The
    // underlying libraries behave differently.
    sql.all(stmt, [], decode.field("1234", decode.int, decode.success))
}

pub fn the_full_experience_test() {
  use db <- sql.with_database(":memory:")
  use create <- result.try(sql.prepare(db, "create table users (name text)"))
  use Nil <- result.try(sql.run(create, []))
  use insert <- result.try(sql.prepare(
    db,
    "insert into users (name) values (?)",
  ))
  use Nil <- result.try(sql.run(insert, [sql.text("Ash")]))
  use Nil <- result.try(sql.run(insert, [sql.text("Misty")]))
  use select_all <- result.try(sql.prepare(db, "select * from users"))
  use users <- result.try(sql.all(
    select_all,
    [],
    decode.field("name", decode.string, decode.success),
  ))

  assert users == ["Ash", "Misty"]
  Ok(Nil)
}

pub fn kitchen_sink_test() {
  let user_decoder = {
    use name <- decode.field("name", decode.string)
    use age <- decode.field("age", decode.int)
    decode.success(#(name, age))
  }
  let raw_user_decoder = {
    use name <- decode.field(0, decode.string)
    use age <- decode.field(1, decode.int)
    decode.success(#(name, age))
  }

  let assert Ok(db) = sql.new_database(":memory:")

  let assert Ok(create_users_table) =
    sql.prepare(db, "create table users (name text, age int)")
  let assert Ok(Nil) = sql.run(create_users_table, [])

  let assert Ok(insert_user) =
    sql.prepare(db, "insert into users (name, age) values (?, ?)")
  let assert Ok(Nil) = sql.run(insert_user, [sql.text("Ash"), sql.int(29)])
  let assert Ok(Nil) = sql.run(insert_user, [sql.text("Misty"), sql.int(31)])
  let assert Ok(Nil) = sql.run(insert_user, [sql.text("Brock"), sql.int(35)])

  let assert Ok(select) = sql.prepare(db, "select * from users where age > ?")

  // Raw returns JS arrays rather than objects, but you must explicitly opt into
  // it.
  let assert Ok(select) = sql.raw(select, True)
  let assert Ok(users) = sql.all(select, [sql.int(30)], raw_user_decoder)
  assert users == [#("Misty", 31), #("Brock", 35)]

  // Switching back to non-raw causes the statement to return JS objects
  // instead.
  let assert Ok(select) = sql.raw(select, False)
  let assert Ok(users) = sql.all(select, [sql.int(30)], user_decoder)
  assert users == [#("Misty", 31), #("Brock", 35)]

  let assert Ok(Nil) = sql.close(db)
}

pub fn raw_cannot_be_called_on_a_statement_that_doesnt_return_data_test() {
  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(create_users_table) =
    sql.prepare(db, "create table users (name text, age int)")
  let assert Ok(Nil) = sql.run(create_users_table, [])
  let assert Ok(insert_user) =
    sql.prepare(db, "insert into users (name, age) values (?, ?)")

  let assert Error(sql.JsError(
    name: "TypeError",
    code: _,
    message: "The raw() method is only for statements that return data",
  )) = sql.raw(insert_user, True)
}
