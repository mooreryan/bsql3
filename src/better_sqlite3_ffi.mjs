import {
  Result$Ok,
  Result$Error,
  Option$Some,
  Option$None,
} from "../gleam.mjs";
import {
  Info$Info,
  Error$SqliteError,
  DatabaseBuilder$DatabaseBuilder$path,
  DatabaseBuilder$DatabaseBuilder$readonly,
  DatabaseBuilder$DatabaseBuilder$file_must_exist,
  DatabaseBuilder$DatabaseBuilder$timeout,
  DatabaseBuilder$DatabaseBuilder$verbose,
  DatabaseBuilder$DatabaseBuilder$native_binding,
} from "./better_sqlite3.mjs";

import Database from "better-sqlite3";

export function new_database(path) {
  try {
    const database = new Database(path);
    return Result$Ok(database);
  } catch (error) {
    return convert_error(error);
  }
}

export function build_database(database_builder) {
  try {
    const database = new Database(
      DatabaseBuilder$DatabaseBuilder$path(database_builder),
      database_options_from_database_builder(options),
    );
    return Result$Ok(database);
  } catch (error) {
    return convert_error(error);
  }
}

function database_options_from_database_builder(database_builder) {
  return {
    readonly: DatabaseBuilder$DatabaseBuilder$readonly(options),
    fileMustExist: DatabaseBuilder$DatabaseBuilder$file_must_exist(options),
    timeout: DatabaseBuilder$DatabaseBuilder$timeout(options),
    verbose: DatabaseBuilder$DatabaseBuilder$verbose(options),
    nativeBinding: DatabaseBuilder$DatabaseBuilder$native_binding(options),
  };
}

export function convert_error(error) {
  return Result$Error(
    Error$SqliteError(
      error.name || "~UNKNOWN~",
      error.code || "~UNKNOWN~",
      error.message || "~UNKNOWN~",
    ),
  );
}
