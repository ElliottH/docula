class Output
  def initialize(db, options)
    @options = options

    @files_stmt = db.prepare(
      "SELECT id, path, docstring FROM files"
    )
    @funcs_stmt = db.prepare(
      "SELECT id, name, type, return, docstring FROM functions
       WHERE file_id = ?"
    )
    @args_stmt = db.prepare(
      "SELECT id, name, type, flow, docstring FROM arguments
       WHERE func_id = ?"
    )
    @vars_stmt = db.prepare(
      "SELECT id, name, type, docstring FROM variables
       WHERE file_id = ?"
    )
    @types_stmt = db.prepare(
      "SELECT id, name, value, docstring FROM typedefs
       WHERE file_id = ?"
    )
    @defs_stmt = db.prepare(
      "SELECT id, name, value, docstring FROM defines
       WHERE file_id = ?"
    )
    @inc_stmt = db.prepare(
      "SELECT files.* FROM files
       INNER JOIN includes on includes.include_id = files.id
       WHERE includes.file_id = ?"
    )

    @type_stmt = db.prepare(
      "SELECT types.*, files.path FROM
       (SELECT id, file_id, name, 'typedef' FROM typedefs WHERE typedefs.name = ?
        UNION ALL
        SELECT id, file_id, name, 'define' FROM defines WHERE defines.name = ?
       ) AS 'types' INNER JOIN files ON types.file_id = files.id"
    )
  end

  def files
    @files_stmt.execute
  end

  def functions(file_id)
    @funcs_stmt.execute(file_id)
  end

  def arguments(func_id)
    @args_stmt.execute(func_id)
  end

  def variables(file_id)
    @vars_stmt.execute(file_id)
  end

  def typedefs(file_id)
    @types_stmt.execute(file_id)
  end

  def defines(file_id)
    @defs_stmt.execute(file_id)
  end

  def includes(file_id)
    @inc_stmt.execute(file_id)
  end

  def type(name)
    @type_stmt.execute(name, name).first
  end
end
