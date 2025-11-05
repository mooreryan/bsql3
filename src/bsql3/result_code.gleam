/// These codes are taken from the better-sqlite cpp code, which takes them from
/// the codes listed here: https://sqlite.org/rescode.html
///
/// There is also a special `Unknown` variant. It represents SQLite errors not
/// recognized by the better-sqlite3 package. See
/// https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#class-sqliteerror
///
pub type ResultCode {

  /// Anything better-sqlite doesn't know about, or, other "unknown" error
  /// strings that are converted into a result code in the `from_string`
  /// function.
  ///
  Unknown(String)

  // Non-error, primary result codes
  Ok
  Row
  Done

  // Primary error codes
  Error
  Internal
  Perm
  Abort
  Busy
  Locked
  Nomem
  Readonly
  Interrupt
  Ioerr
  Corrupt
  Notfound
  Full
  Cantopen
  Protocol
  Empty
  Schema
  Toobig
  Constraint
  Mismatch
  Misuse
  Nolfs
  Auth
  Format
  Range
  Notadb
  Notice
  Warning

  // Extended error codes
  ErrorMissingCollseq
  ErrorRetry
  ErrorSnapshot
  IoerrRead
  IoerrShortRead
  IoerrWrite
  IoerrFsync
  IoerrDirFsync
  IoerrTruncate
  IoerrFstat
  IoerrUnlock
  IoerrRdlock
  IoerrDelete
  IoerrBlocked
  IoerrNomem
  IoerrAccess
  IoerrCheckreservedlock
  IoerrLock
  IoerrClose
  IoerrDirClose
  IoerrShmopen
  IoerrShmsize
  IoerrShmlock
  IoerrShmmap
  IoerrSeek
  IoerrDeleteNoent
  IoerrMmap
  IoerrGettemppath
  IoerrConvpath
  IoerrVnode
  IoerrAuth
  IoerrBeginAtomic
  IoerrCommitAtomic
  IoerrRollbackAtomic
  IoerrData
  IoerrCorruptfs
  IoerrInPage
  LockedSharedcache
  LockedVtab
  BusyRecovery
  BusySnapshot
  CantopenNotempdir
  CantopenIsdir
  CantopenFullpath
  CantopenConvpath
  CantopenDirtywal
  CantopenSymlink
  CorruptVtab
  CorruptSequence
  CorruptIndex
  ReadonlyRecovery
  ReadonlyCantlock
  ReadonlyRollback
  ReadonlyDbmoved
  ReadonlyCantinit
  ReadonlyDirectory
  AbortRollback
  ConstraintCheck
  ConstraintCommithook
  ConstraintForeignkey
  ConstraintFunction
  ConstraintNotnull
  ConstraintPrimarykey
  ConstraintTrigger
  ConstraintUnique
  ConstraintVtab
  ConstraintRowid
  ConstraintPinned
  ConstraintDatatype
  NoticeRecoverWal
  NoticeRecoverRollback
  NoticeRbu
  WarningAutoindex
  AuthUser
  OkLoadPermanently
  OkSymlink
}

pub fn to_string(result_code: ResultCode) -> String {
  case result_code {
    Unknown(code) -> "SQLITE_UNKNOWN(" <> code <> ")"
    Ok -> "SQLITE_OK"
    Row -> "SQLITE_ROW"
    Done -> "SQLITE_DONE"
    Error -> "SQLITE_ERROR"
    Internal -> "SQLITE_INTERNAL"
    Perm -> "SQLITE_PERM"
    Abort -> "SQLITE_ABORT"
    Busy -> "SQLITE_BUSY"
    Locked -> "SQLITE_LOCKED"
    Nomem -> "SQLITE_NOMEM"
    Readonly -> "SQLITE_READONLY"
    Interrupt -> "SQLITE_INTERRUPT"
    Ioerr -> "SQLITE_IOERR"
    Corrupt -> "SQLITE_CORRUPT"
    Notfound -> "SQLITE_NOTFOUND"
    Full -> "SQLITE_FULL"
    Cantopen -> "SQLITE_CANTOPEN"
    Protocol -> "SQLITE_PROTOCOL"
    Empty -> "SQLITE_EMPTY"
    Schema -> "SQLITE_SCHEMA"
    Toobig -> "SQLITE_TOOBIG"
    Constraint -> "SQLITE_CONSTRAINT"
    Mismatch -> "SQLITE_MISMATCH"
    Misuse -> "SQLITE_MISUSE"
    Nolfs -> "SQLITE_NOLFS"
    Auth -> "SQLITE_AUTH"
    Format -> "SQLITE_FORMAT"
    Range -> "SQLITE_RANGE"
    Notadb -> "SQLITE_NOTADB"
    Notice -> "SQLITE_NOTICE"
    Warning -> "SQLITE_WARNING"
    ErrorMissingCollseq -> "SQLITE_ERROR_MISSING_COLLSEQ"
    ErrorRetry -> "SQLITE_ERROR_RETRY"
    ErrorSnapshot -> "SQLITE_ERROR_SNAPSHOT"
    IoerrRead -> "SQLITE_IOERR_READ"
    IoerrShortRead -> "SQLITE_IOERR_SHORT_READ"
    IoerrWrite -> "SQLITE_IOERR_WRITE"
    IoerrFsync -> "SQLITE_IOERR_FSYNC"
    IoerrDirFsync -> "SQLITE_IOERR_DIR_FSYNC"
    IoerrTruncate -> "SQLITE_IOERR_TRUNCATE"
    IoerrFstat -> "SQLITE_IOERR_FSTAT"
    IoerrUnlock -> "SQLITE_IOERR_UNLOCK"
    IoerrRdlock -> "SQLITE_IOERR_RDLOCK"
    IoerrDelete -> "SQLITE_IOERR_DELETE"
    IoerrBlocked -> "SQLITE_IOERR_BLOCKED"
    IoerrNomem -> "SQLITE_IOERR_NOMEM"
    IoerrAccess -> "SQLITE_IOERR_ACCESS"
    IoerrCheckreservedlock -> "SQLITE_IOERR_CHECKRESERVEDLOCK"
    IoerrLock -> "SQLITE_IOERR_LOCK"
    IoerrClose -> "SQLITE_IOERR_CLOSE"
    IoerrDirClose -> "SQLITE_IOERR_DIR_CLOSE"
    IoerrShmopen -> "SQLITE_IOERR_SHMOPEN"
    IoerrShmsize -> "SQLITE_IOERR_SHMSIZE"
    IoerrShmlock -> "SQLITE_IOERR_SHMLOCK"
    IoerrShmmap -> "SQLITE_IOERR_SHMMAP"
    IoerrSeek -> "SQLITE_IOERR_SEEK"
    IoerrDeleteNoent -> "SQLITE_IOERR_DELETE_NOENT"
    IoerrMmap -> "SQLITE_IOERR_MMAP"
    IoerrGettemppath -> "SQLITE_IOERR_GETTEMPPATH"
    IoerrConvpath -> "SQLITE_IOERR_CONVPATH"
    IoerrVnode -> "SQLITE_IOERR_VNODE"
    IoerrAuth -> "SQLITE_IOERR_AUTH"
    IoerrBeginAtomic -> "SQLITE_IOERR_BEGIN_ATOMIC"
    IoerrCommitAtomic -> "SQLITE_IOERR_COMMIT_ATOMIC"
    IoerrRollbackAtomic -> "SQLITE_IOERR_ROLLBACK_ATOMIC"
    IoerrData -> "SQLITE_IOERR_DATA"
    IoerrCorruptfs -> "SQLITE_IOERR_CORRUPTFS"
    IoerrInPage -> "SQLITE_IOERR_IN_PAGE"
    LockedSharedcache -> "SQLITE_LOCKED_SHAREDCACHE"
    LockedVtab -> "SQLITE_LOCKED_VTAB"
    BusyRecovery -> "SQLITE_BUSY_RECOVERY"
    BusySnapshot -> "SQLITE_BUSY_SNAPSHOT"
    CantopenNotempdir -> "SQLITE_CANTOPEN_NOTEMPDIR"
    CantopenIsdir -> "SQLITE_CANTOPEN_ISDIR"
    CantopenFullpath -> "SQLITE_CANTOPEN_FULLPATH"
    CantopenConvpath -> "SQLITE_CANTOPEN_CONVPATH"
    CantopenDirtywal -> "SQLITE_CANTOPEN_DIRTYWAL"
    CantopenSymlink -> "SQLITE_CANTOPEN_SYMLINK"
    CorruptVtab -> "SQLITE_CORRUPT_VTAB"
    CorruptSequence -> "SQLITE_CORRUPT_SEQUENCE"
    CorruptIndex -> "SQLITE_CORRUPT_INDEX"
    ReadonlyRecovery -> "SQLITE_READONLY_RECOVERY"
    ReadonlyCantlock -> "SQLITE_READONLY_CANTLOCK"
    ReadonlyRollback -> "SQLITE_READONLY_ROLLBACK"
    ReadonlyDbmoved -> "SQLITE_READONLY_DBMOVED"
    ReadonlyCantinit -> "SQLITE_READONLY_CANTINIT"
    ReadonlyDirectory -> "SQLITE_READONLY_DIRECTORY"
    AbortRollback -> "SQLITE_ABORT_ROLLBACK"
    ConstraintCheck -> "SQLITE_CONSTRAINT_CHECK"
    ConstraintCommithook -> "SQLITE_CONSTRAINT_COMMITHOOK"
    ConstraintForeignkey -> "SQLITE_CONSTRAINT_FOREIGNKEY"
    ConstraintFunction -> "SQLITE_CONSTRAINT_FUNCTION"
    ConstraintNotnull -> "SQLITE_CONSTRAINT_NOTNULL"
    ConstraintPrimarykey -> "SQLITE_CONSTRAINT_PRIMARYKEY"
    ConstraintTrigger -> "SQLITE_CONSTRAINT_TRIGGER"
    ConstraintUnique -> "SQLITE_CONSTRAINT_UNIQUE"
    ConstraintVtab -> "SQLITE_CONSTRAINT_VTAB"
    ConstraintRowid -> "SQLITE_CONSTRAINT_ROWID"
    ConstraintPinned -> "SQLITE_CONSTRAINT_PINNED"
    ConstraintDatatype -> "SQLITE_CONSTRAINT_DATATYPE"
    NoticeRecoverWal -> "SQLITE_NOTICE_RECOVER_WAL"
    NoticeRecoverRollback -> "SQLITE_NOTICE_RECOVER_ROLLBACK"
    NoticeRbu -> "SQLITE_NOTICE_RBU"
    WarningAutoindex -> "SQLITE_WARNING_AUTOINDEX"
    AuthUser -> "SQLITE_AUTH_USER"
    OkLoadPermanently -> "SQLITE_OK_LOAD_PERMANENTLY"
    OkSymlink -> "SQLITE_OK_SYMLINK"
  }
}

pub fn from_string(code: String) -> ResultCode {
  case code {
    "SQLITE_OK" -> Ok
    "SQLITE_ROW" -> Row
    "SQLITE_DONE" -> Done
    "SQLITE_ERROR" -> Error
    "SQLITE_INTERNAL" -> Internal
    "SQLITE_PERM" -> Perm
    "SQLITE_ABORT" -> Abort
    "SQLITE_BUSY" -> Busy
    "SQLITE_LOCKED" -> Locked
    "SQLITE_NOMEM" -> Nomem
    "SQLITE_READONLY" -> Readonly
    "SQLITE_INTERRUPT" -> Interrupt
    "SQLITE_IOERR" -> Ioerr
    "SQLITE_CORRUPT" -> Corrupt
    "SQLITE_NOTFOUND" -> Notfound
    "SQLITE_FULL" -> Full
    "SQLITE_CANTOPEN" -> Cantopen
    "SQLITE_PROTOCOL" -> Protocol
    "SQLITE_EMPTY" -> Empty
    "SQLITE_SCHEMA" -> Schema
    "SQLITE_TOOBIG" -> Toobig
    "SQLITE_CONSTRAINT" -> Constraint
    "SQLITE_MISMATCH" -> Mismatch
    "SQLITE_MISUSE" -> Misuse
    "SQLITE_NOLFS" -> Nolfs
    "SQLITE_AUTH" -> Auth
    "SQLITE_FORMAT" -> Format
    "SQLITE_RANGE" -> Range
    "SQLITE_NOTADB" -> Notadb
    "SQLITE_NOTICE" -> Notice
    "SQLITE_WARNING" -> Warning
    "SQLITE_ERROR_MISSING_COLLSEQ" -> ErrorMissingCollseq
    "SQLITE_ERROR_RETRY" -> ErrorRetry
    "SQLITE_ERROR_SNAPSHOT" -> ErrorSnapshot
    "SQLITE_IOERR_READ" -> IoerrRead
    "SQLITE_IOERR_SHORT_READ" -> IoerrShortRead
    "SQLITE_IOERR_WRITE" -> IoerrWrite
    "SQLITE_IOERR_FSYNC" -> IoerrFsync
    "SQLITE_IOERR_DIR_FSYNC" -> IoerrDirFsync
    "SQLITE_IOERR_TRUNCATE" -> IoerrTruncate
    "SQLITE_IOERR_FSTAT" -> IoerrFstat
    "SQLITE_IOERR_UNLOCK" -> IoerrUnlock
    "SQLITE_IOERR_RDLOCK" -> IoerrRdlock
    "SQLITE_IOERR_DELETE" -> IoerrDelete
    "SQLITE_IOERR_BLOCKED" -> IoerrBlocked
    "SQLITE_IOERR_NOMEM" -> IoerrNomem
    "SQLITE_IOERR_ACCESS" -> IoerrAccess
    "SQLITE_IOERR_CHECKRESERVEDLOCK" -> IoerrCheckreservedlock
    "SQLITE_IOERR_LOCK" -> IoerrLock
    "SQLITE_IOERR_CLOSE" -> IoerrClose
    "SQLITE_IOERR_DIR_CLOSE" -> IoerrDirClose
    "SQLITE_IOERR_SHMOPEN" -> IoerrShmopen
    "SQLITE_IOERR_SHMSIZE" -> IoerrShmsize
    "SQLITE_IOERR_SHMLOCK" -> IoerrShmlock
    "SQLITE_IOERR_SHMMAP" -> IoerrShmmap
    "SQLITE_IOERR_SEEK" -> IoerrSeek
    "SQLITE_IOERR_DELETE_NOENT" -> IoerrDeleteNoent
    "SQLITE_IOERR_MMAP" -> IoerrMmap
    "SQLITE_IOERR_GETTEMPPATH" -> IoerrGettemppath
    "SQLITE_IOERR_CONVPATH" -> IoerrConvpath
    "SQLITE_IOERR_VNODE" -> IoerrVnode
    "SQLITE_IOERR_AUTH" -> IoerrAuth
    "SQLITE_IOERR_BEGIN_ATOMIC" -> IoerrBeginAtomic
    "SQLITE_IOERR_COMMIT_ATOMIC" -> IoerrCommitAtomic
    "SQLITE_IOERR_ROLLBACK_ATOMIC" -> IoerrRollbackAtomic
    "SQLITE_IOERR_DATA" -> IoerrData
    "SQLITE_IOERR_CORRUPTFS" -> IoerrCorruptfs
    "SQLITE_IOERR_IN_PAGE" -> IoerrInPage
    "SQLITE_LOCKED_SHAREDCACHE" -> LockedSharedcache
    "SQLITE_LOCKED_VTAB" -> LockedVtab
    "SQLITE_BUSY_RECOVERY" -> BusyRecovery
    "SQLITE_BUSY_SNAPSHOT" -> BusySnapshot
    "SQLITE_CANTOPEN_NOTEMPDIR" -> CantopenNotempdir
    "SQLITE_CANTOPEN_ISDIR" -> CantopenIsdir
    "SQLITE_CANTOPEN_FULLPATH" -> CantopenFullpath
    "SQLITE_CANTOPEN_CONVPATH" -> CantopenConvpath
    "SQLITE_CANTOPEN_DIRTYWAL" -> CantopenDirtywal
    "SQLITE_CANTOPEN_SYMLINK" -> CantopenSymlink
    "SQLITE_CORRUPT_VTAB" -> CorruptVtab
    "SQLITE_CORRUPT_SEQUENCE" -> CorruptSequence
    "SQLITE_CORRUPT_INDEX" -> CorruptIndex
    "SQLITE_READONLY_RECOVERY" -> ReadonlyRecovery
    "SQLITE_READONLY_CANTLOCK" -> ReadonlyCantlock
    "SQLITE_READONLY_ROLLBACK" -> ReadonlyRollback
    "SQLITE_READONLY_DBMOVED" -> ReadonlyDbmoved
    "SQLITE_READONLY_CANTINIT" -> ReadonlyCantinit
    "SQLITE_READONLY_DIRECTORY" -> ReadonlyDirectory
    "SQLITE_ABORT_ROLLBACK" -> AbortRollback
    "SQLITE_CONSTRAINT_CHECK" -> ConstraintCheck
    "SQLITE_CONSTRAINT_COMMITHOOK" -> ConstraintCommithook
    "SQLITE_CONSTRAINT_FOREIGNKEY" -> ConstraintForeignkey
    "SQLITE_CONSTRAINT_FUNCTION" -> ConstraintFunction
    "SQLITE_CONSTRAINT_NOTNULL" -> ConstraintNotnull
    "SQLITE_CONSTRAINT_PRIMARYKEY" -> ConstraintPrimarykey
    "SQLITE_CONSTRAINT_TRIGGER" -> ConstraintTrigger
    "SQLITE_CONSTRAINT_UNIQUE" -> ConstraintUnique
    "SQLITE_CONSTRAINT_VTAB" -> ConstraintVtab
    "SQLITE_CONSTRAINT_ROWID" -> ConstraintRowid
    "SQLITE_CONSTRAINT_PINNED" -> ConstraintPinned
    "SQLITE_CONSTRAINT_DATATYPE" -> ConstraintDatatype
    "SQLITE_NOTICE_RECOVER_WAL" -> NoticeRecoverWal
    "SQLITE_NOTICE_RECOVER_ROLLBACK" -> NoticeRecoverRollback
    "SQLITE_NOTICE_RBU" -> NoticeRbu
    "SQLITE_WARNING_AUTOINDEX" -> WarningAutoindex
    "SQLITE_AUTH_USER" -> AuthUser
    "SQLITE_OK_LOAD_PERMANENTLY" -> OkLoadPermanently
    "SQLITE_OK_SYMLINK" -> OkSymlink

    // We don't differentiate between bogus error strings and real unknowns like
    // the UNKNOWN_SQLITE_ERROR_NNNN that better-sqlite3 uses.
    other -> Unknown(other)
  }
}
