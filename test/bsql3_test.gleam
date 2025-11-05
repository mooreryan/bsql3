import bsql3 as sql
import bsql3/result_code
import gleam/dynamic/decode.{type Decoder}
import gleam/io
import gleam/option.{None, Some}
import gleeunit
import qcheck

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn syntax_error_test() {
  let assert Ok(db) = sql.new_database(":memory:")

  let assert Error(sql.SqliteError(code: result_code.Error, message: _)) =
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

fn raw_user_decoder() -> Decoder(User) {
  use id <- decode.field(0, decode.int)
  use name <- decode.field(1, decode.string)
  use age <- decode.field(2, decode.int)
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

  let assert Ok(sql.RunInfo(changes: 1, last_insert_row_id: 1)) =
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

  let assert Ok(sql.RunInfo(changes: 1, last_insert_row_id: 1)) =
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
    code: result_code.ConstraintForeignkey,
    message: "FOREIGN KEY constraint failed",
  )) = sql.exec(db, "INSERT INTO posts (user_id) VALUES (1234)")

  // Turn the foreign keys off and we can insert
  let assert Ok(Nil) = sql.pragma(db, "foreign_keys = OFF")

  let assert Ok(Nil) = sql.exec(db, "INSERT INTO posts (user_id) VALUES (1234)")

  let assert Ok(Nil) = sql.close(db)
}

pub fn kitchen_sink_test() {
  let user_decoder = {
    use id <- decode.field("id", decode.int)
    use name <- decode.field("name", decode.string)
    use age <- decode.field("age", decode.int)
    decode.success(#(id, name, age))
  }
  let raw_user_decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use age <- decode.field(2, decode.int)
    decode.success(#(id, name, age))
  }

  let assert Ok(db) = sql.new_database(":memory:")

  let assert Ok(create_users_table) =
    sql.prepare(
      db,
      "create table users (id integer primary key, name text, age int)",
    )
  let assert Ok(_) = sql.run(create_users_table, [])

  // You can use db exec directly to insert users, but you probably shouldn't
  // since you can't get the rowid back....
  let assert Ok(Nil) =
    sql.exec(db, "insert into users (name, age) values ('Ash', 29)")

  // Inserting users with statement.run
  let assert Ok(insert_user) =
    sql.prepare(db, "insert into users (name, age) values (?, ?)")
  let assert Ok(sql.RunInfo(changes: 1, last_insert_row_id: 2)) =
    sql.run(insert_user, [sql.text("Misty"), sql.int(31)])

  // Inserting users while returning values
  let assert Ok(insert_user_returning) =
    sql.prepare(db, "insert into users (name, age) values (?, ?) returning *")
  let assert Ok([#(3, "Brock", 35)]) =
    sql.all(
      insert_user_returning,
      [sql.text("Brock"), sql.int(35)],
      user_decoder,
    )

  let assert Ok(select) = sql.prepare(db, "select * from users where age > ?")

  // Raw returns JS arrays rather than objects, but you must explicitly opt into
  // it.
  let assert Ok(select) = sql.raw(select, True)
  let assert Ok(users) = sql.all(select, [sql.int(30)], raw_user_decoder)
  assert users == [#(2, "Misty", 31), #(3, "Brock", 35)]

  // Switching back to non-raw causes the statement to return JS objects
  // instead.
  let assert Ok(select) = sql.raw(select, False)
  let assert Ok(users) = sql.all(select, [sql.int(30)], user_decoder)
  assert users == [#(2, "Misty", 31), #(3, "Brock", 35)]

  let assert Ok(Some(#(2, "Misty", 31))) =
    sql.get(select, [sql.int(30)], user_decoder)
  let assert Ok(None) = sql.get(select, [sql.int(50)], user_decoder)

  // Counting rows
  let assert Ok(count_users) = sql.prepare(db, "select count(*) from users")
  let assert Ok([3]) =
    sql.all(
      count_users,
      [],
      decode.field("count(*)", decode.int, decode.success),
    )

  let assert Ok(Nil) = sql.close(db)
}

pub fn raw_cannot_be_called_on_a_statement_that_doesnt_return_data_test() {
  let assert Ok(db) = sql.new_database(":memory:")
  let assert Ok(create_users_table) =
    sql.prepare(db, "create table users (name text, age int)")
  let assert Ok(_) = sql.run(create_users_table, [])
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
      qcheck.option_from(qcheck.uniform_int()),
      qcheck.option_from(qcheck.float()),
      qcheck.option_from(qcheck.bool()),
      qcheck.option_from(qcheck.string()),
      // Non byte-aligned bit arrays don't always round trip in JS due to the
      // way the decoder works.
      qcheck.option_from(qcheck.byte_aligned_bit_array()),
    )
    #(an_int, a_float, a_bool, some_text, a_blob)
  }

  let decoder = {
    use an_int <- decode.field(0, decode.optional(decode.int))
    use a_float <- decode.field(1, decode.optional(decode.float))
    use a_bool <- decode.field(2, decode.optional(sql.decode_bool()))
    use some_text <- decode.field(3, decode.optional(decode.string))
    use a_blob <- decode.field(4, decode.optional(decode.bit_array))
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
          sql.nullable(sql.int, an_int),
          sql.nullable(sql.float, a_float),
          sql.nullable(sql.bool, a_bool),
          sql.nullable(sql.text, some_text),
          sql.nullable(sql.blob, a_blob),
        ],
        decoder,
      )
    assert row == #(an_int, a_float, a_bool, some_text, a_blob)

    // Check `get` as well
    let assert Ok(Some(row)) =
      sql.get(
        stmt,
        [
          sql.nullable(sql.int, an_int),
          sql.nullable(sql.float, a_float),
          sql.nullable(sql.bool, a_bool),
          sql.nullable(sql.text, some_text),
          sql.nullable(sql.blob, a_blob),
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
    code: result_code.Readonly,
    message: "attempt to write a readonly database",
  )) = sql.exec(db, "create table users (name text)")

  let assert Ok(Nil) = sql.close(db)

  delete_file_if_exists(db_name)
}

@external(javascript, "./bsql3_test_ffi.mjs", "temp_db_name")
fn temp_db_name() -> String

//
@external(javascript, "./bsql3_test_ffi.mjs", "delete_file_if_exists")
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

pub fn readme_example_test() {
  // Open a new in-memory database connection.
  //
  let assert Ok(db) = sql.new_database(":memory:")

  // Prepare a statement for creating the users table. You could also imagine
  // using `exec` for this, especially if you have to create a bunch of tables.
  //
  let assert Ok(create_users_table) =
    sql.prepare(
      db,
      "create table users (id integer primary key, name text, age int)",
    )
  let assert Ok(_) = sql.run(create_users_table, [])

  // The `run` function returns a `RunInfo` value that gives you some info about
  // what happened when running the statement.
  //

  let assert Ok(insert_user) =
    sql.prepare(db, "insert into users (name, age) values (?, ?)")
  let assert Ok(sql.RunInfo(changes: 1, last_insert_row_id: 1)) =
    sql.run(insert_user, [sql.text("Ash"), sql.int(29)])

  // Next, we use `all` since we want to get back some data about the inserted
  // rows. You could also use `get` for this if you prefer.
  //

  // This statement will return the ID field of the inserted row.
  //
  let assert Ok(insert_user_returning_id) =
    sql.prepare(db, "insert into users (name, age) values (?, ?) returning id")
  let assert Ok([2]) =
    sql.all(
      insert_user_returning_id,
      [sql.text("Misty"), sql.int(31)],
      // Do you see how the key matches the name of the field/column we asked to
      // return?
      decode.field("id", decode.int, decode.success),
    )

  // This statement will return all the fields of the inserted row. Useful for
  // construting "row return types".
  //
  let assert Ok(insert_user_returning_all_fields) =
    sql.prepare(db, "insert into users (name, age) values (?, ?) returning *")
  let assert Ok([User(id: 3, name: "Brock", age: 35)]) =
    sql.all(
      insert_user_returning_all_fields,
      [sql.text("Brock"), sql.int(35)],
      user_decoder(),
    )

  // Selecting data
  //

  let assert Ok(select) = sql.prepare(db, "select * from users where age > ?")

  // By default, JS objects represent the rows. So you need to decode
  // accordingly.
  //
  let assert Ok(select) = sql.raw(select, False)
  let assert Ok(users) = sql.all(select, [sql.int(30)], user_decoder())
  assert users
    == [
      User(id: 2, name: "Misty", age: 31),
      User(id: 3, name: "Brock", age: 35),
    ]

  // An empty list will be returned if no results are found.
  //
  let assert Ok(users) = sql.all(select, [sql.int(50)], user_decoder())
  assert users == []

  // Sometimes you might want the data returned to be represented by JS arrays rather than JS objects. You can use the `raw` function for that.
  //
  let assert Ok(select) = sql.raw(select, True)
  let assert Ok(users) = sql.all(select, [sql.int(30)], raw_user_decoder())
  assert users
    == [
      User(id: 2, name: "Misty", age: 31),
      User(id: 3, name: "Brock", age: 35),
    ]

  // If you want, you can limit to the first result only using `get`.
  //
  // Note that we switch back to the non-raw, object-returning statement.
  //
  let assert Ok(select) = sql.raw(select, False)
  let assert Ok(Some(User(id: 2, name: "Misty", age: 31))) =
    sql.get(select, [sql.int(30)], user_decoder())

  // Get will return `None` if no results are found.
  //
  let assert Ok(None) = sql.get(select, [sql.int(50)], user_decoder())

  // Counting rows
  //
  let assert Ok(count_users) = sql.prepare(db, "select count(*) from users")
  let assert Ok([3]) =
    sql.all(
      count_users,
      [],
      // Note that the field key will be `count(*)` for this query.
      decode.field("count(*)", decode.int, decode.success),
    )

  // Don't forget to close your DB connection when you're done!
  let assert Ok(Nil) = sql.close(db)
}
