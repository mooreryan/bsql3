import { randomBytes } from "crypto";
import { unlinkSync, existsSync } from "fs";
import { tmpdir } from "os";
import { join } from "path";

export function temp_db_name() {
  const random = randomBytes(16).toString("hex");
  const filename = `test-${Date.now()}-${random}.db`;
  return join(tmpdir(), filename);
}

export function delete_file_if_exists(filepath) {
  if (existsSync(filepath)) {
    unlinkSync(filepath);
  }
}
