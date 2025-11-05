import bsql3/result_code.{type ResultCode}
import gleam/dynamic/decode.{type Decoder, type Dynamic}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

pub type Error {
  /// Errors that originate in the JS FFI code, but that are not SQLite3 errors.
  ///
  /// For example, better-sqlite will throw a JavaScript TypeError in certain
  /// situations like when trying to call the `raw` method on a
  /// statement that does not return data.
  ///
  JsError(name: String, message: String)

  /// Also originates from the JS FFI code, but specific to sqlite errors.
  ///
  SqliteError(code: ResultCode, message: String)

  /// Decoding errors. If you get one of these, you need to fix your decoder.
  ///
  DecodeError(errors: List(decode.DecodeError))
}

// ---------------------------------------------------------------------------
// Databatse connections -----------------------------------------------------
// ---------------------------------------------------------------------------

pub type Database

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

@external(javascript, "./bsql3_ffi.mjs", "new_database")
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

@external(javascript, "./bsql3_ffi.mjs", "build_database")
pub fn build(database_builder: DatabaseBuilder) -> Result(Database, Error)

@external(javascript, "./bsql3_ffi.mjs", "exec")
pub fn exec(database: Database, sql: String) -> Result(Nil, Error)

@external(javascript, "./bsql3_ffi.mjs", "prepare")
pub fn prepare(database: Database, sql: String) -> Result(Statement, Error)

@external(javascript, "./bsql3_ffi.mjs", "close")
pub fn close(database: Database) -> Result(Nil, Error)

// Database properties
//
// These are taken from the better-sqlite3 docs
//
// .open -> boolean - Whether the database connection is currently open.
// .inTransaction -> boolean - Whether the database connection is currently in an open transaction.
// .name -> string - The string that was used to open the database connection.
// .memory -> boolean - Whether the database is an in-memory or temporary database.
// .readonly -> boolean - Whether the database connection was created in readonly mode.

@external(javascript, "./bsql3_ffi.mjs", "database_open")
pub fn database_open(database: Database) -> Bool

@external(javascript, "./bsql3_ffi.mjs", "database_in_transaction")
pub fn database_in_transaction(database: Database) -> Bool

@external(javascript, "./bsql3_ffi.mjs", "database_name")
pub fn database_name(database: Database) -> String

@external(javascript, "./bsql3_ffi.mjs", "database_memory")
pub fn database_memory(database: Database) -> Bool

@external(javascript, "./bsql3_ffi.mjs", "database_readonly")
pub fn database_readonly(database: Database) -> Bool

// ---------------------------------------------------------------------------
// Statements ----------------------------------------------------------------
// ---------------------------------------------------------------------------

pub type Statement

pub fn all(
  statement: Statement,
  with bind_parameters: List(Value),
  expecting decoder: Decoder(a),
) -> Result(List(a), Error) {
  use rows <- result.try(do_all(statement, bind_parameters))
  list.try_map(over: rows, with: fn(row) { decode.run(row, decoder) })
  |> result.map_error(DecodeError)
}

@external(javascript, "./bsql3_ffi.mjs", "all")
fn do_all(
  statement: Statement,
  with bind_parameters: List(Value),
) -> Result(List(Dynamic), Error)

pub fn get(
  statement: Statement,
  with bind_parameters: List(Value),
  expecting decoder: Decoder(a),
) -> Result(Option(a), Error) {
  use maybe_row <- result.try(do_get(statement, bind_parameters))
  decode.run(maybe_row, decode.optional(decoder))
  |> result.map_error(DecodeError)
}

@external(javascript, "./bsql3_ffi.mjs", "get")
fn do_get(
  statement: Statement,
  with bind_parameters: List(Value),
) -> Result(Dynamic, Error)

pub type RunInfo {
  RunInfo(changes: Int, last_insert_row_id: Int)
}

fn run_info_decoder() -> Decoder(RunInfo) {
  use changes <- decode.field("changes", decode.int)
  use last_insert_row_id <- decode.field("lastInsertRowid", decode.int)
  decode.success(RunInfo(changes:, last_insert_row_id:))
}

/// If this results in a DecodeError, it should be considered as a bug in this
/// library. If this happens, please open an issue on the GitHub repository.
/// Thanks!
///
pub fn run(
  statement: Statement,
  with bind_parameters: List(Value),
) -> Result(RunInfo, Error) {
  use run_info_object <- result.try(do_run(statement, bind_parameters))
  decode.run(run_info_object, run_info_decoder())
  |> result.map_error(DecodeError)
}

@external(javascript, "./bsql3_ffi.mjs", "run")
fn do_run(
  statement: Statement,
  with bind_parameters: List(Value),
) -> Result(Dynamic, Error)

/// Will return an `Error` if you call it on a statement that doesn't return data.
///
@external(javascript, "./bsql3_ffi.mjs", "raw")
pub fn raw(statement: Statement, toggle_raw: Bool) -> Result(Statement, Error)

// Statement properties

@external(javascript, "./bsql3_ffi.mjs", "statement_database")
pub fn statement_database(statement: Statement) -> Database

@external(javascript, "./bsql3_ffi.mjs", "statement_source")
pub fn statement_source(statement: Statement) -> String

@external(javascript, "./bsql3_ffi.mjs", "statement_reader")
pub fn statement_reader(statement: Statement) -> Bool

@external(javascript, "./bsql3_ffi.mjs", "statement_readonly")
pub fn statement_readonly(statement: Statement) -> Bool

// ---------------------------------------------------------------------------
// Pragmas -------------------------------------------------------------------
// ---------------------------------------------------------------------------

@external(javascript, "./bsql3_ffi.mjs", "pragma")
pub fn pragma(database: Database, sql: String) -> Result(Nil, Error)

pub fn pragma_simple(
  database: Database,
  sql: String,
  expecting decoder: Decoder(a),
) -> Result(a, Error) {
  use value <- result.try(do_pragma_simple(database, sql))
  decode.run(value, decoder) |> result.map_error(DecodeError)
}

@external(javascript, "./bsql3_ffi.mjs", "pragma_simple")
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

@external(javascript, "./bsql3_ffi.mjs", "pragma_all")
fn do_pragma_all(
  database: Database,
  sql: String,
) -> Result(List(Dynamic), Error)

// ---------------------------------------------------------------------------
// Values --------------------------------------------------------------------
// ---------------------------------------------------------------------------

pub type Value

@external(javascript, "./bsql3_ffi.mjs", "coerce")
fn coerce(a: a) -> Value

/// Convert a Gleam `Option` to an SQLite nullable value for use as a bind
/// parameter.
///
pub fn nullable(coerce: fn(a) -> Value, value: Option(a)) -> Value {
  case value {
    Some(value) -> coerce(value)
    None -> null()
  }
}

/// Convert a Gleam `Int` to an SQLite int for use as a bind parameter.
///
pub fn int(value: Int) -> Value {
  coerce(value)
}

/// Convert a Gleam `Float` to an SQLite float for use as a bind parameter.
///
pub fn float(value: Float) -> Value {
  coerce(value)
}

/// Convert a Gleam `String` to an SQLite text for use as a bind parameter.
///
pub fn text(value: String) -> Value {
  coerce(value)
}

/// Convert a Gleam `BitString` to an SQLite blob for use as a bind parameter.
///
@external(javascript, "./bsql3_ffi.mjs", "coerce_blob")
pub fn blob(value: BitArray) -> Value

/// Convert a Gleam `Bool` to an SQLite int for use as a bind parameter.
///
/// SQLite does not have a native boolean type. Instead, it uses ints, where 0
/// is False and 1 is True. Because of this the Gleam stdlib decoder for bools
/// will not work, instead the `decode_bool` function should be used as it
/// supports both ints and bools.
///
pub fn bool(value: Bool) -> Value {
  case value {
    True -> int(1)
    False -> int(0)
  }
}

/// Construct an SQLite null for use as a bind parameter.
///
@external(javascript, "./bsql3_ffi.mjs", "null_")
pub fn null() -> Value

/// Decode an SQLite boolean value.
///
/// Decodes 0 as `False` and any other integer as `True`.
///
pub fn decode_bool() -> Decoder(Bool) {
  use bool <- decode.then(decode.int)

  case bool {
    0 -> decode.success(False)
    _ -> decode.success(True)
  }
}
