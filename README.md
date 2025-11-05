# bsql3

Relatively faithful bindings to [better-sqlite3](https://github.com/WiseLibs/better-sqlite3), a SQLite3 library for Node.js.

This package follows function and type names from the better-sqlite3 package when possible.

## Example Usage

Here is an example using many of this packages common functions. This example uses `let assert`. In your own code, you probably want to set up a more robust error handling strategy.

```gleam
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
```

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/gleam_qcheck)

Copyright (c) 2025 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.

See the `licenses` directory for info on code that has been adapted from other packages.
