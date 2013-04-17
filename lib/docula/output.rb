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
    @other_inc_stmt = db.prepare(
      "SELECT * FROM other_includes
       WHERE file_id = ?")

    @type_stmt = db.prepare(
      "SELECT types.*, files.path FROM
       (SELECT id, file_id, name, 'typedef' FROM typedefs WHERE typedefs.name = ?
        UNION ALL
        SELECT id, file_id, name, 'define' FROM defines WHERE defines.name = ?
       ) AS 'types' INNER JOIN files ON types.file_id = files.id"
    )

    @func_stmt = db.prepare(
      "SELECT functions.*, files.path FROM functions
       INNER JOIN files on functions.file_id = files.id
       WHERE functions.id = ?"
    )
    @equiv_funcs_stmt = db.prepare(
      "SELECT id, name, type FROM functions WHERE name = ?"
    )
    @equiv_args_stmt = db.prepare(
      "SELECT name, type FROM arguments WHERE func_id = ? ORDER BY name"
    )
  end

  def files
    @files_stmt.execute
  end

  def functions(file_id)
    @funcs_stmt.execute(file_id)
  end

  def function(func_id)
    @func_stmt.execute(func_id).next
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

  def other_includes(file_id)
    @other_inc_stmt.execute(file_id)
  end

  def type(name)
    @type_stmt.execute(name, name).first
  end

  def equiv_args(first, second)
    first_args = @equiv_args_stmt.execute(first)
    second_args = @equiv_args_stmt.execute(second)

    while (fargs = first_args.next) && (sargs = second_args.next)
      unless fargs['name'] == sargs['name'] && fargs['type'] == sargs['type']
        return false
      end
    end

    # first_args.zip(second_args).each do |pair|
    #   puts pair
    #   unless first_args['name'] == second_args['name'] &&
    #     first_args['type'] == second_args['type']
    #     return false
    #   end
    # end

    true
  end

  def equiv_function(id)
    function = @func_stmt.execute(id).next
    id, name, type = function['id'], function['name'], function['type']
    functions = @equiv_funcs_stmt.execute(name)

    equiv = []
    functions.each do |func|
      if name == func['name'] && type == func['type']
        equiv << func['id'] if equiv_args(id, func['id'])
      end
    end

    equiv - [id]
  end
end
