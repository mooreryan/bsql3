import gleam/option.{type Option, None}

pub type Error {
  SqliteError(name: String, code: String, message: String)
}

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
