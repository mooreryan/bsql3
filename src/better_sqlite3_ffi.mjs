import { List, Result$Ok, Result$Error } from "./gleam.mjs";
import { Option$isSome, Option$Some$0 } from "../gleam_stdlib/gleam/option.mjs";

import {
  Error$JsError,
  Error$SqliteError,
  DatabaseBuilder$DatabaseBuilder$path,
  DatabaseBuilder$DatabaseBuilder$readonly,
  DatabaseBuilder$DatabaseBuilder$file_must_exist,
  DatabaseBuilder$DatabaseBuilder$timeout,
  DatabaseBuilder$DatabaseBuilder$verbose,
  DatabaseBuilder$DatabaseBuilder$native_binding,
} from "./better_sqlite3.mjs";

import { from_string as result_code_from_string } from "./better_sqlite3/result_code.mjs";

import Database from "better-sqlite3";

// ---------------------------------------------------------------------------
// Databatse connections -----------------------------------------------------
// ---------------------------------------------------------------------------

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
      database_options_from_database_builder(database_builder),
    );
    return Result$Ok(database);
  } catch (error) {
    return convert_error(error);
  }
}

function database_options_from_database_builder(database_builder) {
  let options = {
    readonly: DatabaseBuilder$DatabaseBuilder$readonly(database_builder),
    fileMustExist:
      DatabaseBuilder$DatabaseBuilder$file_must_exist(database_builder),
    timeout: DatabaseBuilder$DatabaseBuilder$timeout(database_builder),
  };

  const verbose = DatabaseBuilder$DatabaseBuilder$verbose(database_builder);
  if (Option$isSome(verbose)) {
    options.verbose = Option$Some$0(verbose);
  }

  const nativeBinding =
    DatabaseBuilder$DatabaseBuilder$native_binding(database_builder);
  if (Option$isSome(nativeBinding)) {
    options.nativeBinding = Option$Some$0(nativeBinding);
  }

  return options;
}

export function exec(database, sql) {
  try {
    // This method returns `this`, but we will return Nil to Gleam
    database.exec(sql);
    return Result$Ok(undefined);
  } catch (error) {
    return convert_error(error);
  }
}

export function prepare(database, sql) {
  try {
    const statement = database.prepare(sql);
    return Result$Ok(statement);
  } catch (error) {
    return convert_error(error);
  }
}

export function close(database) {
  try {
    database.close();
    return Result$Ok(undefined);
  } catch (error) {
    return convert_error(error);
  }
}

// DB properties

export function database_open(database) {
  return database.open;
}

export function database_in_transaction(database) {
  return database.inTransaction;
}

export function database_name(database) {
  return database.name;
}

export function database_memory(database) {
  return database.memory;
}

export function database_readonly(database) {
  return database.readonly;
}

// ---------------------------------------------------------------------------
// Statements ----------------------------------------------------------------
// ---------------------------------------------------------------------------

export function run(statement, bind_parameters) {
  try {
    const info = statement.run(bind_parameters.toArray());
    return Result$Ok(info);
  } catch (error) {
    return convert_error(error);
  }
}

export function all(statement, bind_parameters) {
  try {
    const rows = statement.all(bind_parameters.toArray());
    return Result$Ok(List.fromArray(rows));
  } catch (error) {
    return convert_error(error);
  }
}

export function get(statement, bind_parameters) {
  try {
    const row = statement.get(bind_parameters.toArray());
    return Result$Ok(row);
  } catch (error) {
    return convert_error(error);
  }
}

export function raw(statement, toggle_raw) {
  try {
    // Raw will throw type errors if it is called on statements that don't
    // return data.
    //
    // See better-sqlite3 -> statement.cpp -> Statement::JS_raw
    const stmt = statement.raw(toggle_raw);
    return Result$Ok(stmt);
  } catch (error) {
    return convert_error(error);
  }
}

// DB properties

export function statement_database(statement) {
  return statement.database;
}

export function statement_source(statement) {
  return statement.source;
}

export function statement_reader(statement) {
  return statement.reader;
}

export function statement_readonly(statement) {
  return statement.readonly;
}

// ---------------------------------------------------------------------------
// Pragmas -------------------------------------------------------------------
// ---------------------------------------------------------------------------

export function pragma(database, sql) {
  try {
    database.pragma(sql);
    return Result$Ok(undefined);
  } catch (error) {
    return convert_error(error);
  }
}

export function pragma_simple(database, sql) {
  try {
    const value = database.pragma(sql, { simple: simple });
    return Result$Ok(value);
  } catch (error) {
    return convert_error(error);
  }
}

export function pragma_all(database, sql) {
  try {
    const value = database.pragma(sql);
    return Result$Ok(List.fromArray(value));
  } catch (error) {
    return convert_error(error);
  }
}

// ---------------------------------------------------------------------------
// Values --------------------------------------------------------------------
// ---------------------------------------------------------------------------

export function null_() {
  return undefined;
}

export function coerce(value) {
  return value;
}

export function coerce_blob(value) {
  return value.rawBuffer;
}

// ---------------------------------------------------------------------------
// Utils ---------------------------------------------------------------------
// ---------------------------------------------------------------------------

function convert_error(error) {
  if (error.code) {
    const result_code = result_code_from_string(error.code);

    return Result$Error(
      Error$SqliteError(result_code, error.message || "~UNKNOWN~"),
    );
  } else {
    return Result$Error(
      Error$JsError(error.name || "~UNKNOWN~", error.message || "~UNKNOWN~"),
    );
  }
}
