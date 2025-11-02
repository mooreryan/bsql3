import gleam/dynamic/decode.{type Decoder, type Dynamic}
import gleam/list
import gleam/option.{type Option, None}
import gleam/result

pub type Error {
  /// Errors that originate in the JS FFI code. Could be a better-sqlite3 error,
  /// could be a regular JS error, etc. The `code` will often be sqlite3 error
  /// codes as returned by the better-sqlite3 package.
  ///
  /// If any of the fields are not present in the error, `"~UNKNOWN~"` will be
  /// used.
  ///
  JsError(name: String, code: String, message: String)
  DecodeError(errors: List(decode.DecodeError))
}

pub type Database

pub type Statement

pub type DatabaseBuilder {
  DatabaseBuilder(
    path: String,
    readonly: Bool,
    file_must_exist: Bool,
    timeout: Int,
    verbose: Option(fn(String) -> Nil),
    native_binding: Option(String),
  )
}

@external(javascript, "./better_sqlite3_ffi.mjs", "new_database")
pub fn new_database(path: String) -> Result(Database, Error)

pub fn database_builder(path: String) -> DatabaseBuilder {
  DatabaseBuilder(
    path:,
    readonly: False,
    file_must_exist: False,
    timeout: 5000,
    verbose: None,
    native_binding: None,
  )
}

pub fn with_path(
  database_builder: DatabaseBuilder,
  path: String,
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, path:)
}

pub fn with_readonly(
  database_builder: DatabaseBuilder,
  readonly: Bool,
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, readonly:)
}

pub fn with_file_must_exist(
  database_builder: DatabaseBuilder,
  file_must_exist: Bool,
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, file_must_exist:)
}

pub fn with_timeout(
  database_builder: DatabaseBuilder,
  timeout: Int,
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, timeout:)
}

pub fn with_verbose(
  database_builder: DatabaseBuilder,
  verbose: Option(fn(String) -> Nil),
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, verbose:)
}

pub fn with_native_binding(
  database_builder: DatabaseBuilder,
  native_binding: Option(String),
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, native_binding:)
}

@external(javascript, "./better_sqlite3_ffi.mjs", "build_database")
pub fn build(database_builder: DatabaseBuilder) -> Result(Database, Error)

@external(javascript, "./better_sqlite3_ffi.mjs", "exec")
pub fn exec(database: Database, sql: String) -> Result(Nil, Error)

@external(javascript, "./better_sqlite3_ffi.mjs", "prepare")
pub fn prepare(database: Database, sql: String) -> Result(Statement, Error)

pub type Value

@external(javascript, "./better_sqlite3_ffi.mjs", "coerce")
pub fn coerce_string(value: String) -> Value

@external(javascript, "./better_sqlite3_ffi.mjs", "coerce")
pub fn coerce_int(value: Int) -> Value

pub fn all(
  statement: Statement,
  with bind_parameters: List(Value),
  expecting decoder: Decoder(a),
) -> Result(List(a), Error) {
  use rows <- result.try(do_all(statement, bind_parameters))
  list.try_map(over: rows, with: fn(row) { decode.run(row, decoder) })
  |> result.map_error(DecodeError)
}

@external(javascript, "./better_sqlite3_ffi.mjs", "all")
fn do_all(
  statement: Statement,
  with bind_parameters: List(Value),
) -> Result(List(Dynamic), Error)

@external(javascript, "./better_sqlite3_ffi.mjs", "run")
pub fn run(
  statement: Statement,
  with bind_parameters: List(Value),
) -> Result(Nil, Error)

@external(javascript, "./better_sqlite3_ffi.mjs", "close")
pub fn close(database: Database) -> Result(Nil, Error)

@external(javascript, "./better_sqlite3_ffi.mjs", "pragma")
pub fn pragma(database: Database, sql: String) -> Result(Nil, Error)

pub fn pragma_simple(
  database: Database,
  sql: String,
  expecting decoder: Decoder(a),
) -> Result(a, Error) {
  use value <- result.try(do_pragma_simple(database, sql))
  decode.run(value, decoder) |> result.map_error(DecodeError)
}

@external(javascript, "./better_sqlite3_ffi.mjs", "pragma_simple")
fn do_pragma_simple(database: Database, sql: String) -> Result(Dynamic, Error)

pub fn pragma_all(
  database: Database,
  sql: String,
  expecting decoder: Decoder(a),
) -> Result(List(a), Error) {
  use rows <- result.try(do_pragma_all(database, sql))
  list.try_map(over: rows, with: fn(row) { decode.run(row, decoder) })
  |> result.map_error(DecodeError)
}

@external(javascript, "./better_sqlite3_ffi.mjs", "pragma_all")
fn do_pragma_all(
  database: Database,
  sql: String,
) -> Result(List(Dynamic), Error)
