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

  assert user.name == "Alice"
  assert user.age == 30
}
