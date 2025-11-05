//// Relatively faithful bindings to the
//// [better-sqlite3](https://github.com/WiseLibs/better-sqlite3) node.js
//// package.
////
//// This package follows function and type names from the better-sqlite3
//// package when possible.
////
//// See the project readme for a usage example.
////
//// For detailed documentation of the original better-sqlite3 package, see the
//// [better-sqlite3
//// wiki](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md).
////
////
//// ## Database connections
////
//// - The [Database](#Database) connection type
////
//// ### Connecting to databases
////
//// With default options:
//// - [new_database](#new_database)
////
//// Database builder:
//// - [database_builder](#database_builder)
//// - [with_file_must_exist](#with_file_must_exist)
//// - [with_native_binding](#with_native_binding)
//// - [with_path](#with_path)
//// - [with_readonly](#with_readonly)
//// - [with_timeout](#with_timeout)
//// - [with_verbose](#with_verbose)
////
//// ### Closing connections
////
//// - [close](#close)
////
//// ### Database operations
////
//// - [exec](#exec)
//// - [pragma](#pragma)
//// - [pragma_all](#pragma_all)
//// - [pragma_simple](#pragma_simple)
//// - [prepare](#prepare)
////
//// ### Database properties
////
//// - [database_in_transaction](#database_in_transaction)
//// - [database_memory](#database_memory)
//// - [database_name](#database_name)
//// - [database_open](#database_open)
//// - [database_readonly](#database_readonly)
////
//// ## Prepared statements
////
//// ### Types
////
//// - The [Statement](#Statement) type
//// - The [RunInfo](#RunInfo) type
////
//// ### Running statements
////
//// - [all](#all)
//// - [get](#get)
//// - [run](#run)
////
//// ### Configuring statements
////
//// - [raw](#raw)
////
//// ### Statement properties
////
//// - [statement_database](#statement_database)
//// - [statement_reader](#statement_reader)
//// - [statement_readonly](#statement_readonly)
//// - [statement_source](#statement_source)
////
//// ## Converting Gleam types to SQLite3 types
////
//// - The [Value](#Value) type
//// - [blob](#blob)
//// - [bool](#bool)
//// - [decode_bool](#decode_bool)
//// - [float](#float)
//// - [int](#int)
//// - [null](#null)
//// - [nullable](#nullable)
//// - [text](#text)
////

import bsql3/result_code.{type ResultCode}
import gleam/dynamic/decode.{type Decoder, type Dynamic}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

/// Error type for the bsql3 package.
///
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

/// Type representing database connections
///
/// See better-sqlite3 docs for [class Database](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#class-database).
///
pub type Database

/// Type representing database builders. You can use this to build up a database
/// connection if you need to specify any options.
///
/// These options are described in the [better-sqlite3 docs](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#class-database).
///
pub type DatabaseBuilder {
  DatabaseBuilder(
    /// Path to the database
    ///
    /// - For in-memory databases, pass `":memory:"`
    /// - For temporaray databases, pass `""`
    ///
    path: String,
    /// Open the database connection in readonly mode. (default `False`)
    ///
    readonly: Bool,
    /// If `True`, then the database file must already exist. This option is
    /// ignored for in-memory, temporary, or readonly database connections.
    /// (default `False`)
    ///
    file_must_exist: Bool,
    /// The number of milliseconds to wait when executing queries on a locked
    /// database, before returning a `result_code.Busy` error. (default: `5000`).
    ///
    timeout: Int,
    /// Provide a function that gets called with every SQL string executed by
    /// the database connection. (default: `None`).
    ///
    verbose: Option(fn(String) -> Nil),
    /// Use this option to provide the file path of better_sqlite3.node
    /// (relative to the current working directory). (default: `None`)
    ///
    /// See the [better-sqlite3 docs](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#new-databasepath-options)
    /// for why you might need to do this.
    ///
    native_binding: Option(String),
  )
}

/// Create a new database connection.
///
/// - For in-memory databases, pass `":memory:"`
/// - For temporaray databases, pass `""`
///
/// See better-sqlite3 docs for [new Database()](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#execstring---this).
///
@external(javascript, "./bsql3_ffi.mjs", "new_database")
pub fn new_database(path: String) -> Result(Database, Error)

/// Create a new `DatabaseBuilder` with the default options.
///
/// See that type's docs for info on defaults.
///
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

/// Update the `path` option in the given `database_builder`.
///
pub fn with_path(
  database_builder: DatabaseBuilder,
  path: String,
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, path:)
}

/// Update the `readonly` option in the given `database_builder`.
///
pub fn with_readonly(
  database_builder: DatabaseBuilder,
  readonly: Bool,
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, readonly:)
}

/// Update the `file_must_exist` option in the given `database_builder`.
///
pub fn with_file_must_exist(
  database_builder: DatabaseBuilder,
  file_must_exist: Bool,
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, file_must_exist:)
}

/// Update the `timeout` option in the given `database_builder`.
///
pub fn with_timeout(
  database_builder: DatabaseBuilder,
  timeout: Int,
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, timeout:)
}

/// Update the `verbose` option in the given `database_builder`.
///
pub fn with_verbose(
  database_builder: DatabaseBuilder,
  verbose: Option(fn(String) -> Nil),
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, verbose:)
}

/// Update the `native_binding` option in the given `database_builder`.
///
pub fn with_native_binding(
  database_builder: DatabaseBuilder,
  native_binding: Option(String),
) -> DatabaseBuilder {
  DatabaseBuilder(..database_builder, native_binding:)
}

/// Builds a database connection from the given `database_builder`.
///
@external(javascript, "./bsql3_ffi.mjs", "build_database")
pub fn build(database_builder: DatabaseBuilder) -> Result(Database, Error)

/// Executes the given SQL string on the database connection.
///
/// - Unlike prepared statements, the SQL string can contain multiple SQL
///   statements.
/// - Performs worse and is less safe than using prepared statements.
/// - Useful for executing SQL statements from an external source (like a file).
/// - If an error occurs, execution stops and further statements are not
///   executed. You must rollback changes manually.
///
/// See better-sqlite3 docs for [Database#exec()](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#execstring---this).
///
@external(javascript, "./bsql3_ffi.mjs", "exec")
pub fn exec(database: Database, sql: String) -> Result(Nil, Error)

/// Creates a new prepared [Statement](#Statement) from the given SQL string.
///
/// See better-sqlite3 docs for [Database#prepare()](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#preparestring---statement).
///
@external(javascript, "./bsql3_ffi.mjs", "prepare")
pub fn prepare(database: Database, sql: String) -> Result(Statement, Error)

/// Closes the database connection.
///
/// After invoking this method, no statements can be created or executed.
///
/// See better-sqlite3 docs for [Database#close()](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#close---this).
///
@external(javascript, "./bsql3_ffi.mjs", "close")
pub fn close(database: Database) -> Result(Nil, Error)

/// Whether the database connection is currently open
///
/// See better-sqlite3 docs for [Database properties](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#properties).
///
@external(javascript, "./bsql3_ffi.mjs", "database_open")
pub fn database_open(database: Database) -> Bool

/// Whether the database connection is currently in an open transaction
///
/// See better-sqlite3 docs for [Database properties](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#properties).
///
/// _Note: Transactions have not yet been implemented in bsql3._
///
@external(javascript, "./bsql3_ffi.mjs", "database_in_transaction")
pub fn database_in_transaction(database: Database) -> Bool

/// The string that was used to open the database connection
///
/// See better-sqlite3 docs for [Database properties](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#properties).
///
@external(javascript, "./bsql3_ffi.mjs", "database_name")
pub fn database_name(database: Database) -> String

/// Whether the database is an in-memory or temporary database
///
/// See better-sqlite3 docs for [Database properties](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#properties).
///
@external(javascript, "./bsql3_ffi.mjs", "database_memory")
pub fn database_memory(database: Database) -> Bool

/// Whether the database connection was created in readonly mode
///
/// See better-sqlite3 docs for [Database properties](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#properties).
///
@external(javascript, "./bsql3_ffi.mjs", "database_readonly")
pub fn database_readonly(database: Database) -> Bool

// ---------------------------------------------------------------------------
// Statements ----------------------------------------------------------------
// ---------------------------------------------------------------------------

/// Type representing a single SQL statement.
///
/// See better-sqlite3 docs for [class Statement](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#class-statement).
///
pub type Statement

/// Execute the prepared statement, returning all "rows" of results.
///
/// - If no rows are found, the list will be empty.
/// - If the execution of the statement fails, an `Error` is returned.
/// - This should only be called on statements that return data.
///
/// The `bind_parameters` are only bound for the given execution.
///
/// See better-sqlite3 docs for [Statement#all()](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#allbindparameters---array-of-rows).
///
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

/// Execute the prepared statement, returning the first "row" of results.
///
/// - If no rows are found, the return value will be `None`.
/// - If the execution of the statement fails, an `Error` is returned.
/// - This should only be called on statements that return data.
///
/// The `bind_parameters` are only bound for the given execution.
///
/// See better-sqlite3 docs for [Statement#get()](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#getbindparameters---row).
///
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

/// Type representing the value returned by the [run](#run) function.
///
pub type RunInfo {
  RunInfo(
    /// Total number of rows that were inserted, updated, or deleted by this
    /// operation. Changes made by [foreign key
    /// actions](https://www.sqlite.org/foreignkeys.html#fk_actions) or [trigger
    /// programs](https://www.sqlite.org/lang_createtrigger.html) do not count.
    ///
    changes: Int,
    /// The [rowid](https://www.sqlite.org/lang_createtable.html#rowid) of the
    /// last row inserted into the database (ignoring those caused by [trigger
    /// programs](https://www.sqlite.org/lang_createtrigger.html)). If the
    /// current statement did not insert any rows into the database, this number
    /// should be completely ignored.
    ///
    last_insert_row_id: Int,
  )
}

fn run_info_decoder() -> Decoder(RunInfo) {
  use changes <- decode.field("changes", decode.int)
  use last_insert_row_id <- decode.field("lastInsertRowid", decode.int)
  decode.success(RunInfo(changes:, last_insert_row_id:))
}

/// Executes the prepared statement with the given `bind_parameters`.
///
/// - Upon successful execution, a [RunInfo](#RunInfo) value describing any
/// changes made is returned.
/// - If statement execution fails, an [Error](#Error) is returned.
///
/// If this results in a DecodeError, you can consider it to be a bug in the
/// bsql3 package. If this happens, please open an issue on the GitHub
/// repository. Thanks!
///
/// See better-sqlite3 docs for [Statement#run()](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#runbindparameters---object).
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

/// Causes the prepared statement to return JS arrays rather than JS objects.
/// This will affect how you need to write your decoders.
///
/// - Will return an `Error` if you call it on a statement that doesn't return data.
/// - This should only be called on statements that return data.
///
@external(javascript, "./bsql3_ffi.mjs", "raw")
pub fn raw(statement: Statement, toggle_raw: Bool) -> Result(Statement, Error)

// Statement properties
//

/// Return the parent [Database](#Database) value.
///
/// See better-sqlite3 docs for [Statement properties](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#properties-1).
///
@external(javascript, "./bsql3_ffi.mjs", "statement_database")
pub fn statement_database(statement: Statement) -> Database

/// The source string that was used to create the prepared statement.
///
/// See better-sqlite3 docs for [Statement properties](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#properties-1).
///
@external(javascript, "./bsql3_ffi.mjs", "statement_source")
pub fn statement_source(statement: Statement) -> String

/// Whether the prepared statement returns data.
///
/// See better-sqlite3 docs for [Statement properties](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#properties-1).
///
@external(javascript, "./bsql3_ffi.mjs", "statement_reader")
pub fn statement_reader(statement: Statement) -> Bool

/// Whether the prepared statement is readonly, meaning it does not mutate the
/// database (note that
/// [SQL functions might still change the database indirectly](https://www.sqlite.org/c3ref/stmt_readonly.html)
/// as a side effect, even if the `readonly` property is true).
///
/// See better-sqlite3 docs for [Statement properties](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#properties-1).
///
@external(javascript, "./bsql3_ffi.mjs", "statement_readonly")
pub fn statement_readonly(statement: Statement) -> Bool

// ---------------------------------------------------------------------------
// Pragmas -------------------------------------------------------------------
// ---------------------------------------------------------------------------

/// Executes the given PRAGMA, ignoring its result.
///
/// You should favor this function for running PRAGMAs rather than using prepared statements.
///
/// - See the SQLite3 docs on [PRAGMA](https://www.sqlite.org/pragma.html)
/// - See better-sqlite3 docs for [Database#pragma()](https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#pragmastring-options---results).
///
@external(javascript, "./bsql3_ffi.mjs", "pragma")
pub fn pragma(database: Database, sql: String) -> Result(Nil, Error)

/// Executes the given PRAGMA in better-sqlite3's "simple" mode, which returns
/// the first column of the first row that will be returned by the PRAGMA. This
/// will affect the decoder you need to write.
///
/// See [pragma](#pragma) for more info.
///
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

/// Executes the given PRAGMA returning all the results.
///
/// If you don't care about the result of the PRAGMA, you can use
/// [pragma](#pragma) instead.
///
/// See [pragma](#pragma) for more info.
///
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

/// Type representing SQLite values for bind parameters.
///
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
/// SQLite3 doesn't have a "boolean" type, in the same way the Gleam does. So
/// you should use this to decode SQLite3 booleans rather than the boolean
/// decoder in Gleam's stdlib.
///
pub fn decode_bool() -> Decoder(Bool) {
  use bool <- decode.then(decode.int)

  case bool {
    0 -> decode.success(False)
    _ -> decode.success(True)
  }
}
