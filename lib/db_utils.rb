class DBUtils
  def self.setup(db)
    db.results_as_hash = true
    db.execute("PRAGMA foreign_keys = ON;")

    db.execute(
      "CREATE TABLE IF NOT EXISTS files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL,
        hash TEXT NOT NULL,
        includes TEXT,
        docstring TEXT,
        exist INTEGER DEFAULT 1)"
    )
    db.execute(
      "CREATE TABLE IF NOT EXISTS variables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_id INTEGER,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        docstring TEXT,
        FOREIGN KEY(file_id) REFERENCES files (id) ON DELETE CASCADE)"
    )
    db.execute(
      "CREATE TABLE IF NOT EXISTS functions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_id INTEGER,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        return TEXT,
        docstring TEXT,
        FOREIGN KEY(file_id) REFERENCES files (id) ON DELETE CASCADE)"
    )
    db.execute(
      "CREATE TABLE IF NOT EXISTS arguments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        func_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        flow TEXT,
        docstring TEXT,
        FOREIGN KEY(func_id) REFERENCES functions (id) ON DELETE CASCADE)"
    )
    db.execute(
      "CREATE TABLE IF NOT EXISTS defines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        value TEXT,
        docstring TEXT,
        FOREIGN KEY(file_id) REFERENCES files (id) ON DELETE CASCADE)")
    db.execute(
      "CREATE TABLE IF NOT EXISTS typedefs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_id INTEGER NOT NULL,
        value TEXT NOT NULL,
        name TEXT NOT NULL,
        docstring TEXT,
        FOREIGN KEY(file_id) REFERENCES files (id) ON DELETE CASCADE)")
  end
end
