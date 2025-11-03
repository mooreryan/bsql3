import better_sqlite3 as sql
import gleam/dynamic/decode.{type Decoder}
import gleam/io
import gleam/option.{Some}
import gleeunit
import qcheck

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn syntax_error_test() {
  let assert Ok(db) = sql.new_database(":memory:")

  let assert Error(sql.SqliteError(code: "SQLITE_ERROR", message: _)) =
    sql.exec(db, "this won't work!")

  let assert Ok(Nil) = sql.close(db)
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
  let assert Error(sql.JsError(_, _)) = sql.exec(db, "SELECT 1")
}

/// The following actions give an error:
///
/// 1. Create DB
/// 2. Prepare a statement on that DB
/// 3. Close the DB connection
/// 4. Try to run/exec the prepared statement
///
pub fn db_close_prepared_statement_test() {
  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(stmt) = sql.prepare(db, "select 1")
  let assert Ok(Nil) = sql.close(db)
  let assert Error(sql.JsError(
    name: "TypeError",
    message: "The database connection is not open",
  )) = sql.all(stmt, [], decode.field("1", decode.int, decode.success))
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
  let assert Error(sql.SqliteError(
    code: "SQLITE_CONSTRAINT_FOREIGNKEY",
    message: "FOREIGN KEY constraint failed",
  )) = sql.exec(db, "INSERT INTO posts (user_id) VALUES (1234)")

  // Turn the foreign keys off and we can insert
  let assert Ok(Nil) = sql.pragma(db, "foreign_keys = OFF")

  let assert Ok(Nil) = sql.exec(db, "INSERT INTO posts (user_id) VALUES (1234)")

  let assert Ok(Nil) = sql.close(db)
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
    message: "The raw() method is only for statements that return data",
  )) = sql.raw(insert_user, True)

  let assert Ok(Nil) = sql.close(db)
}

pub fn coerce_roundtrip_test() {
  let generator = {
    use an_int, a_float, a_bool, some_text, a_blob <- qcheck.map5(
      qcheck.uniform_int(),
      qcheck.float(),
      qcheck.bool(),
      qcheck.string(),
      // Non byte-aligned bit arrays don't always round trip in JS due to the
      // way the decoder works.
      qcheck.byte_aligned_bit_array(),
    )
    #(an_int, a_float, a_bool, some_text, a_blob)
  }

  let decoder = {
    use an_int <- decode.field(0, decode.int)
    use a_float <- decode.field(1, decode.float)
    use a_bool <- decode.field(2, sql.decode_bool())
    use some_text <- decode.field(3, decode.string)
    use a_blob <- decode.field(4, decode.bit_array)
    decode.success(#(an_int, a_float, a_bool, some_text, a_blob))
  }

  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(stmt) = sql.prepare(db, "select ?, ?, ?, ?, ?")
  let assert Ok(stmt) = sql.raw(stmt, True)

  let Nil = {
    use #(an_int, a_float, a_bool, some_text, a_blob) <- qcheck.given(generator)
    let assert Ok([row]) =
      sql.all(
        stmt,
        [
          sql.int(an_int),
          sql.float(a_float),
          sql.bool(a_bool),
          sql.text(some_text),
          sql.blob(a_blob),
        ],
        decoder,
      )

    assert row == #(an_int, a_float, a_bool, some_text, a_blob)
  }

  let assert Ok(Nil) = sql.close(db)
}

pub fn database_properties_test() {
  let assert Ok(db) = sql.new_database(":memory:")

  assert sql.database_open(db) == True
  assert sql.database_in_transaction(db) == False
  assert sql.database_name(db) == ":memory:"
  assert sql.database_memory(db) == True
  assert sql.database_readonly(db) == False

  let assert Ok(Nil) = sql.close(db)
}

pub fn verbose_db_test() {
  let assert Ok(db) =
    sql.database_builder(":memory:")
    |> sql.with_verbose(
      Some(fn(x) { io.println_error("\nVERBOSE DB SAYS: " <> x) }),
    )
    |> sql.build()

  let assert Ok(stmt) = sql.prepare(db, "select 1")
  let assert Ok([row]) =
    sql.all(stmt, [], decode.field("1", decode.int, decode.success))
  let assert Ok(Nil) = sql.close(db)

  assert row == 1
}

pub fn readonly_db_test() {
  let db_name = temp_db_name()
  let assert Ok(db) = sql.new_database("/Users/ryan/Desktop/test.db")
  let assert Ok(Nil) = sql.close(db)

  let assert Ok(db) =
    sql.database_builder("/Users/ryan/Desktop/test.db")
    |> sql.with_readonly(True)
    |> sql.build()

  let assert Error(sql.SqliteError(
    code: "SQLITE_READONLY",
    message: "attempt to write a readonly database",
  )) = sql.exec(db, "create table users (name text)")

  let assert Ok(Nil) = sql.close(db)

  delete_file_if_exists(db_name)
}

@external(javascript, "./better_sqlite3_test_ffi.mjs", "temp_db_name")
fn temp_db_name() -> String

//
@external(javascript, "./better_sqlite3_test_ffi.mjs", "delete_file_if_exists")
fn delete_file_if_exists(path: String) -> Nil

pub fn statement_properties_test() {
  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(stmt) = sql.prepare(db, "select 1")

  assert sql.statement_database(stmt) == db
  assert sql.statement_source(stmt) == "select 1"
  assert sql.statement_reader(stmt) == True
  assert sql.statement_readonly(stmt) == True

  let assert Ok(Nil) = sql.close(db)
}
