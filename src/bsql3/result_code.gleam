/// These codes are taken from the better-sqlite cpp code, which takes them from
/// the codes listed here: https://sqlite.org/rescode.html
///
/// The sqlite code names are converted to PascalCase variant names in this way:
/// - First letter stays capitalized
/// - Letters directly following an underscore stay capitalized
/// - All remaining letters are lowercased
///
/// There is also a special `SqliteUnknown` variant. It represents SQLite errors
/// not recognized by the better-sqlite3 package. See
/// https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md#class-sqliteerror
///
pub type ResultCode {

  /// Anything better-sqlite doesn't know about, or, other "unknown" error
  /// strings that are converted into a result code in the `from_string`
  /// function.
  ///
  SqliteUnknown(String)

  // Non-error, primary result codes
  SqliteOk
  SqliteRow
  SqliteDone

  // Primary error codes
  SqliteError
  SqliteInternal
  SqlitePerm
  SqliteAbort
  SqliteBusy
  SqliteLocked
  SqliteNomem
  SqliteReadonly
  SqliteInterrupt
  SqliteIoerr
  SqliteCorrupt
  SqliteNotfound
  SqliteFull
  SqliteCantopen
  SqliteProtocol
  SqliteEmpty
  SqliteSchema
  SqliteToobig
  SqliteConstraint
  SqliteMismatch
  SqliteMisuse
  SqliteNolfs
  SqliteAuth
  SqliteFormat
  SqliteRange
  SqliteNotadb
  SqliteNotice
  SqliteWarning

  // Extended error codes
  SqliteErrorMissingCollseq
  SqliteErrorRetry
  SqliteErrorSnapshot
  SqliteIoerrRead
  SqliteIoerrShortRead
  SqliteIoerrWrite
  SqliteIoerrFsync
  SqliteIoerrDirFsync
  SqliteIoerrTruncate
  SqliteIoerrFstat
  SqliteIoerrUnlock
  SqliteIoerrRdlock
  SqliteIoerrDelete
  SqliteIoerrBlocked
  SqliteIoerrNomem
  SqliteIoerrAccess
  SqliteIoerrCheckreservedlock
  SqliteIoerrLock
  SqliteIoerrClose
  SqliteIoerrDirClose
  SqliteIoerrShmopen
  SqliteIoerrShmsize
  SqliteIoerrShmlock
  SqliteIoerrShmmap
  SqliteIoerrSeek
  SqliteIoerrDeleteNoent
  SqliteIoerrMmap
  SqliteIoerrGettemppath
  SqliteIoerrConvpath
  SqliteIoerrVnode
  SqliteIoerrAuth
  SqliteIoerrBeginAtomic
  SqliteIoerrCommitAtomic
  SqliteIoerrRollbackAtomic
  SqliteIoerrData
  SqliteIoerrCorruptfs
  SqliteIoerrInPage
  SqliteLockedSharedcache
  SqliteLockedVtab
  SqliteBusyRecovery
  SqliteBusySnapshot
  SqliteCantopenNotempdir
  SqliteCantopenIsdir
  SqliteCantopenFullpath
  SqliteCantopenConvpath
  SqliteCantopenDirtywal
  SqliteCantopenSymlink
  SqliteCorruptVtab
  SqliteCorruptSequence
  SqliteCorruptIndex
  SqliteReadonlyRecovery
  SqliteReadonlyCantlock
  SqliteReadonlyRollback
  SqliteReadonlyDbmoved
  SqliteReadonlyCantinit
  SqliteReadonlyDirectory
  SqliteAbortRollback
  SqliteConstraintCheck
  SqliteConstraintCommithook
  SqliteConstraintForeignkey
  SqliteConstraintFunction
  SqliteConstraintNotnull
  SqliteConstraintPrimarykey
  SqliteConstraintTrigger
  SqliteConstraintUnique
  SqliteConstraintVtab
  SqliteConstraintRowid
  SqliteConstraintPinned
  SqliteConstraintDatatype
  SqliteNoticeRecoverWal
  SqliteNoticeRecoverRollback
  SqliteNoticeRbu
  SqliteWarningAutoindex
  SqliteAuthUser
  SqliteOkLoadPermanently
  SqliteOkSymlink
}

pub fn to_string(result_code: ResultCode) -> String {
  case result_code {
    SqliteUnknown(code) -> "SQLITE_UNKNOWN(" <> code <> ")"
    SqliteOk -> "SQLITE_OK"
    SqliteRow -> "SQLITE_ROW"
    SqliteDone -> "SQLITE_DONE"
    SqliteError -> "SQLITE_ERROR"
    SqliteInternal -> "SQLITE_INTERNAL"
    SqlitePerm -> "SQLITE_PERM"
    SqliteAbort -> "SQLITE_ABORT"
    SqliteBusy -> "SQLITE_BUSY"
    SqliteLocked -> "SQLITE_LOCKED"
    SqliteNomem -> "SQLITE_NOMEM"
    SqliteReadonly -> "SQLITE_READONLY"
    SqliteInterrupt -> "SQLITE_INTERRUPT"
    SqliteIoerr -> "SQLITE_IOERR"
    SqliteCorrupt -> "SQLITE_CORRUPT"
    SqliteNotfound -> "SQLITE_NOTFOUND"
    SqliteFull -> "SQLITE_FULL"
    SqliteCantopen -> "SQLITE_CANTOPEN"
    SqliteProtocol -> "SQLITE_PROTOCOL"
    SqliteEmpty -> "SQLITE_EMPTY"
    SqliteSchema -> "SQLITE_SCHEMA"
    SqliteToobig -> "SQLITE_TOOBIG"
    SqliteConstraint -> "SQLITE_CONSTRAINT"
    SqliteMismatch -> "SQLITE_MISMATCH"
    SqliteMisuse -> "SQLITE_MISUSE"
    SqliteNolfs -> "SQLITE_NOLFS"
    SqliteAuth -> "SQLITE_AUTH"
    SqliteFormat -> "SQLITE_FORMAT"
    SqliteRange -> "SQLITE_RANGE"
    SqliteNotadb -> "SQLITE_NOTADB"
    SqliteNotice -> "SQLITE_NOTICE"
    SqliteWarning -> "SQLITE_WARNING"
    SqliteErrorMissingCollseq -> "SQLITE_ERROR_MISSING_COLLSEQ"
    SqliteErrorRetry -> "SQLITE_ERROR_RETRY"
    SqliteErrorSnapshot -> "SQLITE_ERROR_SNAPSHOT"
    SqliteIoerrRead -> "SQLITE_IOERR_READ"
    SqliteIoerrShortRead -> "SQLITE_IOERR_SHORT_READ"
    SqliteIoerrWrite -> "SQLITE_IOERR_WRITE"
    SqliteIoerrFsync -> "SQLITE_IOERR_FSYNC"
    SqliteIoerrDirFsync -> "SQLITE_IOERR_DIR_FSYNC"
    SqliteIoerrTruncate -> "SQLITE_IOERR_TRUNCATE"
    SqliteIoerrFstat -> "SQLITE_IOERR_FSTAT"
    SqliteIoerrUnlock -> "SQLITE_IOERR_UNLOCK"
    SqliteIoerrRdlock -> "SQLITE_IOERR_RDLOCK"
    SqliteIoerrDelete -> "SQLITE_IOERR_DELETE"
    SqliteIoerrBlocked -> "SQLITE_IOERR_BLOCKED"
    SqliteIoerrNomem -> "SQLITE_IOERR_NOMEM"
    SqliteIoerrAccess -> "SQLITE_IOERR_ACCESS"
    SqliteIoerrCheckreservedlock -> "SQLITE_IOERR_CHECKRESERVEDLOCK"
    SqliteIoerrLock -> "SQLITE_IOERR_LOCK"
    SqliteIoerrClose -> "SQLITE_IOERR_CLOSE"
    SqliteIoerrDirClose -> "SQLITE_IOERR_DIR_CLOSE"
    SqliteIoerrShmopen -> "SQLITE_IOERR_SHMOPEN"
    SqliteIoerrShmsize -> "SQLITE_IOERR_SHMSIZE"
    SqliteIoerrShmlock -> "SQLITE_IOERR_SHMLOCK"
    SqliteIoerrShmmap -> "SQLITE_IOERR_SHMMAP"
    SqliteIoerrSeek -> "SQLITE_IOERR_SEEK"
    SqliteIoerrDeleteNoent -> "SQLITE_IOERR_DELETE_NOENT"
    SqliteIoerrMmap -> "SQLITE_IOERR_MMAP"
    SqliteIoerrGettemppath -> "SQLITE_IOERR_GETTEMPPATH"
    SqliteIoerrConvpath -> "SQLITE_IOERR_CONVPATH"
    SqliteIoerrVnode -> "SQLITE_IOERR_VNODE"
    SqliteIoerrAuth -> "SQLITE_IOERR_AUTH"
    SqliteIoerrBeginAtomic -> "SQLITE_IOERR_BEGIN_ATOMIC"
    SqliteIoerrCommitAtomic -> "SQLITE_IOERR_COMMIT_ATOMIC"
    SqliteIoerrRollbackAtomic -> "SQLITE_IOERR_ROLLBACK_ATOMIC"
    SqliteIoerrData -> "SQLITE_IOERR_DATA"
    SqliteIoerrCorruptfs -> "SQLITE_IOERR_CORRUPTFS"
    SqliteIoerrInPage -> "SQLITE_IOERR_IN_PAGE"
    SqliteLockedSharedcache -> "SQLITE_LOCKED_SHAREDCACHE"
    SqliteLockedVtab -> "SQLITE_LOCKED_VTAB"
    SqliteBusyRecovery -> "SQLITE_BUSY_RECOVERY"
    SqliteBusySnapshot -> "SQLITE_BUSY_SNAPSHOT"
    SqliteCantopenNotempdir -> "SQLITE_CANTOPEN_NOTEMPDIR"
    SqliteCantopenIsdir -> "SQLITE_CANTOPEN_ISDIR"
    SqliteCantopenFullpath -> "SQLITE_CANTOPEN_FULLPATH"
    SqliteCantopenConvpath -> "SQLITE_CANTOPEN_CONVPATH"
    SqliteCantopenDirtywal -> "SQLITE_CANTOPEN_DIRTYWAL"
    SqliteCantopenSymlink -> "SQLITE_CANTOPEN_SYMLINK"
    SqliteCorruptVtab -> "SQLITE_CORRUPT_VTAB"
    SqliteCorruptSequence -> "SQLITE_CORRUPT_SEQUENCE"
    SqliteCorruptIndex -> "SQLITE_CORRUPT_INDEX"
    SqliteReadonlyRecovery -> "SQLITE_READONLY_RECOVERY"
    SqliteReadonlyCantlock -> "SQLITE_READONLY_CANTLOCK"
    SqliteReadonlyRollback -> "SQLITE_READONLY_ROLLBACK"
    SqliteReadonlyDbmoved -> "SQLITE_READONLY_DBMOVED"
    SqliteReadonlyCantinit -> "SQLITE_READONLY_CANTINIT"
    SqliteReadonlyDirectory -> "SQLITE_READONLY_DIRECTORY"
    SqliteAbortRollback -> "SQLITE_ABORT_ROLLBACK"
    SqliteConstraintCheck -> "SQLITE_CONSTRAINT_CHECK"
    SqliteConstraintCommithook -> "SQLITE_CONSTRAINT_COMMITHOOK"
    SqliteConstraintForeignkey -> "SQLITE_CONSTRAINT_FOREIGNKEY"
    SqliteConstraintFunction -> "SQLITE_CONSTRAINT_FUNCTION"
    SqliteConstraintNotnull -> "SQLITE_CONSTRAINT_NOTNULL"
    SqliteConstraintPrimarykey -> "SQLITE_CONSTRAINT_PRIMARYKEY"
    SqliteConstraintTrigger -> "SQLITE_CONSTRAINT_TRIGGER"
    SqliteConstraintUnique -> "SQLITE_CONSTRAINT_UNIQUE"
    SqliteConstraintVtab -> "SQLITE_CONSTRAINT_VTAB"
    SqliteConstraintRowid -> "SQLITE_CONSTRAINT_ROWID"
    SqliteConstraintPinned -> "SQLITE_CONSTRAINT_PINNED"
    SqliteConstraintDatatype -> "SQLITE_CONSTRAINT_DATATYPE"
    SqliteNoticeRecoverWal -> "SQLITE_NOTICE_RECOVER_WAL"
    SqliteNoticeRecoverRollback -> "SQLITE_NOTICE_RECOVER_ROLLBACK"
    SqliteNoticeRbu -> "SQLITE_NOTICE_RBU"
    SqliteWarningAutoindex -> "SQLITE_WARNING_AUTOINDEX"
    SqliteAuthUser -> "SQLITE_AUTH_USER"
    SqliteOkLoadPermanently -> "SQLITE_OK_LOAD_PERMANENTLY"
    SqliteOkSymlink -> "SQLITE_OK_SYMLINK"
  }
}

pub fn from_string(code: String) -> ResultCode {
  case code {
    "SQLITE_OK" -> SqliteOk
    "SQLITE_ROW" -> SqliteRow
    "SQLITE_DONE" -> SqliteDone
    "SQLITE_ERROR" -> SqliteError
    "SQLITE_INTERNAL" -> SqliteInternal
    "SQLITE_PERM" -> SqlitePerm
    "SQLITE_ABORT" -> SqliteAbort
    "SQLITE_BUSY" -> SqliteBusy
    "SQLITE_LOCKED" -> SqliteLocked
    "SQLITE_NOMEM" -> SqliteNomem
    "SQLITE_READONLY" -> SqliteReadonly
    "SQLITE_INTERRUPT" -> SqliteInterrupt
    "SQLITE_IOERR" -> SqliteIoerr
    "SQLITE_CORRUPT" -> SqliteCorrupt
    "SQLITE_NOTFOUND" -> SqliteNotfound
    "SQLITE_FULL" -> SqliteFull
    "SQLITE_CANTOPEN" -> SqliteCantopen
    "SQLITE_PROTOCOL" -> SqliteProtocol
    "SQLITE_EMPTY" -> SqliteEmpty
    "SQLITE_SCHEMA" -> SqliteSchema
    "SQLITE_TOOBIG" -> SqliteToobig
    "SQLITE_CONSTRAINT" -> SqliteConstraint
    "SQLITE_MISMATCH" -> SqliteMismatch
    "SQLITE_MISUSE" -> SqliteMisuse
    "SQLITE_NOLFS" -> SqliteNolfs
    "SQLITE_AUTH" -> SqliteAuth
    "SQLITE_FORMAT" -> SqliteFormat
    "SQLITE_RANGE" -> SqliteRange
    "SQLITE_NOTADB" -> SqliteNotadb
    "SQLITE_NOTICE" -> SqliteNotice
    "SQLITE_WARNING" -> SqliteWarning
    "SQLITE_ERROR_MISSING_COLLSEQ" -> SqliteErrorMissingCollseq
    "SQLITE_ERROR_RETRY" -> SqliteErrorRetry
    "SQLITE_ERROR_SNAPSHOT" -> SqliteErrorSnapshot
    "SQLITE_IOERR_READ" -> SqliteIoerrRead
    "SQLITE_IOERR_SHORT_READ" -> SqliteIoerrShortRead
    "SQLITE_IOERR_WRITE" -> SqliteIoerrWrite
    "SQLITE_IOERR_FSYNC" -> SqliteIoerrFsync
    "SQLITE_IOERR_DIR_FSYNC" -> SqliteIoerrDirFsync
    "SQLITE_IOERR_TRUNCATE" -> SqliteIoerrTruncate
    "SQLITE_IOERR_FSTAT" -> SqliteIoerrFstat
    "SQLITE_IOERR_UNLOCK" -> SqliteIoerrUnlock
    "SQLITE_IOERR_RDLOCK" -> SqliteIoerrRdlock
    "SQLITE_IOERR_DELETE" -> SqliteIoerrDelete
    "SQLITE_IOERR_BLOCKED" -> SqliteIoerrBlocked
    "SQLITE_IOERR_NOMEM" -> SqliteIoerrNomem
    "SQLITE_IOERR_ACCESS" -> SqliteIoerrAccess
    "SQLITE_IOERR_CHECKRESERVEDLOCK" -> SqliteIoerrCheckreservedlock
    "SQLITE_IOERR_LOCK" -> SqliteIoerrLock
    "SQLITE_IOERR_CLOSE" -> SqliteIoerrClose
    "SQLITE_IOERR_DIR_CLOSE" -> SqliteIoerrDirClose
    "SQLITE_IOERR_SHMOPEN" -> SqliteIoerrShmopen
    "SQLITE_IOERR_SHMSIZE" -> SqliteIoerrShmsize
    "SQLITE_IOERR_SHMLOCK" -> SqliteIoerrShmlock
    "SQLITE_IOERR_SHMMAP" -> SqliteIoerrShmmap
    "SQLITE_IOERR_SEEK" -> SqliteIoerrSeek
    "SQLITE_IOERR_DELETE_NOENT" -> SqliteIoerrDeleteNoent
    "SQLITE_IOERR_MMAP" -> SqliteIoerrMmap
    "SQLITE_IOERR_GETTEMPPATH" -> SqliteIoerrGettemppath
    "SQLITE_IOERR_CONVPATH" -> SqliteIoerrConvpath
    "SQLITE_IOERR_VNODE" -> SqliteIoerrVnode
    "SQLITE_IOERR_AUTH" -> SqliteIoerrAuth
    "SQLITE_IOERR_BEGIN_ATOMIC" -> SqliteIoerrBeginAtomic
    "SQLITE_IOERR_COMMIT_ATOMIC" -> SqliteIoerrCommitAtomic
    "SQLITE_IOERR_ROLLBACK_ATOMIC" -> SqliteIoerrRollbackAtomic
    "SQLITE_IOERR_DATA" -> SqliteIoerrData
    "SQLITE_IOERR_CORRUPTFS" -> SqliteIoerrCorruptfs
    "SQLITE_IOERR_IN_PAGE" -> SqliteIoerrInPage
    "SQLITE_LOCKED_SHAREDCACHE" -> SqliteLockedSharedcache
    "SQLITE_LOCKED_VTAB" -> SqliteLockedVtab
    "SQLITE_BUSY_RECOVERY" -> SqliteBusyRecovery
    "SQLITE_BUSY_SNAPSHOT" -> SqliteBusySnapshot
    "SQLITE_CANTOPEN_NOTEMPDIR" -> SqliteCantopenNotempdir
    "SQLITE_CANTOPEN_ISDIR" -> SqliteCantopenIsdir
    "SQLITE_CANTOPEN_FULLPATH" -> SqliteCantopenFullpath
    "SQLITE_CANTOPEN_CONVPATH" -> SqliteCantopenConvpath
    "SQLITE_CANTOPEN_DIRTYWAL" -> SqliteCantopenDirtywal
    "SQLITE_CANTOPEN_SYMLINK" -> SqliteCantopenSymlink
    "SQLITE_CORRUPT_VTAB" -> SqliteCorruptVtab
    "SQLITE_CORRUPT_SEQUENCE" -> SqliteCorruptSequence
    "SQLITE_CORRUPT_INDEX" -> SqliteCorruptIndex
    "SQLITE_READONLY_RECOVERY" -> SqliteReadonlyRecovery
    "SQLITE_READONLY_CANTLOCK" -> SqliteReadonlyCantlock
    "SQLITE_READONLY_ROLLBACK" -> SqliteReadonlyRollback
    "SQLITE_READONLY_DBMOVED" -> SqliteReadonlyDbmoved
    "SQLITE_READONLY_CANTINIT" -> SqliteReadonlyCantinit
    "SQLITE_READONLY_DIRECTORY" -> SqliteReadonlyDirectory
    "SQLITE_ABORT_ROLLBACK" -> SqliteAbortRollback
    "SQLITE_CONSTRAINT_CHECK" -> SqliteConstraintCheck
    "SQLITE_CONSTRAINT_COMMITHOOK" -> SqliteConstraintCommithook
    "SQLITE_CONSTRAINT_FOREIGNKEY" -> SqliteConstraintForeignkey
    "SQLITE_CONSTRAINT_FUNCTION" -> SqliteConstraintFunction
    "SQLITE_CONSTRAINT_NOTNULL" -> SqliteConstraintNotnull
    "SQLITE_CONSTRAINT_PRIMARYKEY" -> SqliteConstraintPrimarykey
    "SQLITE_CONSTRAINT_TRIGGER" -> SqliteConstraintTrigger
    "SQLITE_CONSTRAINT_UNIQUE" -> SqliteConstraintUnique
    "SQLITE_CONSTRAINT_VTAB" -> SqliteConstraintVtab
    "SQLITE_CONSTRAINT_ROWID" -> SqliteConstraintRowid
    "SQLITE_CONSTRAINT_PINNED" -> SqliteConstraintPinned
    "SQLITE_CONSTRAINT_DATATYPE" -> SqliteConstraintDatatype
    "SQLITE_NOTICE_RECOVER_WAL" -> SqliteNoticeRecoverWal
    "SQLITE_NOTICE_RECOVER_ROLLBACK" -> SqliteNoticeRecoverRollback
    "SQLITE_NOTICE_RBU" -> SqliteNoticeRbu
    "SQLITE_WARNING_AUTOINDEX" -> SqliteWarningAutoindex
    "SQLITE_AUTH_USER" -> SqliteAuthUser
    "SQLITE_OK_LOAD_PERMANENTLY" -> SqliteOkLoadPermanently
    "SQLITE_OK_SYMLINK" -> SqliteOkSymlink

    // We don't differentiate between bogus error strings and real unknowns like
    // the UNKNOWN_SQLITE_ERROR_NNNN that better-sqlite3 uses.
    other -> SqliteUnknown(other)
  }
}
