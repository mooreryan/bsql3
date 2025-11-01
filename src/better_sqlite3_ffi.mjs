// import { Result$Ok, Result$Error, Option$Some, Option$None } from "./gleam.mjs";
import { List, Result$Ok, Result$Error } from "./gleam.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import {
  Option$None,
  Option$isNone,
  Option$Some,
  Option$isSome,
  Option$Some$0,
} from "../gleam_stdlib/gleam/option.mjs";

import {
  Error$JsError,
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

  return opts;
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
    // TODO: I'm not sure if this method can actually fail?
    const statement = database.prepare(sql);
    return Result$Ok(statement);
  } catch (error) {
    return convert_error(error);
  }
}

export function run(statement, bind_parameters) {
  try {
    const result = statement.run(bind_parameters.toArray());
    // TODO: return the real object
    return Result$Ok(undefined);
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

export function coerce(value) {
  return value;
}

export function close(database) {
  try {
    database.close();
    return Result$Ok(undefined);
  } catch (error) {
    return convert_error(error);
  }
}

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
// Utils ---------------------------------------------------------------------
// ---------------------------------------------------------------------------

export function convert_error(error) {
  return Result$Error(
    Error$JsError(
      error.name || "~UNKNOWN~",
      error.code || "~UNKNOWN~",
      error.message || "~UNKNOWN~",
    ),
  );
}
