class Input
  def initialize(db, options)
    @options = options
    @db = db
    @includes = {}

    @var_stmt = @db.prepare(
      "INSERT INTO variables (file_id, name, type, docstring)
       VALUES (?, ?, ?, ?)"
    )
    @func_stmt = @db.prepare(
      "INSERT INTO functions (file_id, name, type, return, docstring)
       VALUES (?, ?, ?, ?, ?)"
    )
    @args_stmt = @db.prepare(
      "INSERT INTO arguments (func_id, name, type, flow, docstring)
       VALUES (?, ?, ?, ?, ?)"
    )
    @defines_stmt = @db.prepare(
      "INSERT INTO defines (file_id, name, value, docstring)
       VALUES (?, ?, ?, ?)"
    )
    @typedef_stmt = @db.prepare(
      "INSERT INTO typedefs (file_id, value, name, docstring)
       VALUES (?, ?, ?, ?)"
    )
    @file_stmt = @db.prepare(
      "SELECT id, path FROM files WHERE id = ?"
    )
    @files_stmt = @db.prepare(
      "SELECT id, path FROM files WHERE path LIKE ?"
    )
    @include_stmt = @db.prepare(
      "INSERT INTO includes (file_id, include_id) VALUES (?, ?)"
    )
  end

  def parse(tree, file_id)
    tree.variables.each do |variable|
      print "Found variable #{variable.Name} with type #{variable.Type}\n" if @options[:verbose]
      @var_stmt.execute(file_id, variable.Name, variable.Type, variable.docstring[:text])
    end

    tree.functions.each do |function|
      print "Found function #{function.prototype[:name]} with return type #{function.prototype[:type]}\n" if @options[:verbose]

      prototype = function.prototype.merge(function.docstring)
      if function.documented?
        prototype[:arguments] = Utils.merge(prototype[:params], prototype[:arguments])
        prototype.delete(:params)
      end

      @func_stmt.execute(file_id, prototype[:name], prototype[:type], prototype[:return], prototype[:text])
      func_id = @db.last_insert_row_id

      prototype[:arguments].each do |arg|
        @args_stmt.execute(func_id, arg[:name], arg[:type], arg[:flow], arg[:description])
      end
    end

    tree.directives.each do |directive|
      if directive.include?
        @includes[file_id] = directive.includes
      elsif directive.define?
        @defines_stmt.execute(file_id, directive.defines[0], directive.defines[1], directive.docstring[:text])
      end
    end

    tree.typedefs.each do |typedef|
      @typedef_stmt.execute(file_id, typedef.from, typedef.to, typedef.docstring[:text])
    end
  end

  def post_process
    @includes.each do |file_id, include|
      file_path = Pathname.new(@file_stmt.execute(file_id).first['path']).dirname

      @files_stmt.execute("%#{File.basename(include)}").each do |file|
        rel_path = Pathname.new(file['path']).relative_path_from(file_path)
        if rel_path.to_s == include
          @include_stmt.execute(file_id, file['id'])
        end
      end
    end
  end
end
