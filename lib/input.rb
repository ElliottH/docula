def parse(tree, db, file_id, options)
  var_stmt = db.prepare("INSERT INTO variables (file_id, name, type, docstring) VALUES (#{file_id}, ?, ?, ?)")
  tree.variables.each do |variable|
    print "Found variable #{variable.Name} with type #{variable.Type}\n" if options[:verbose]
    var_stmt.execute(variable.Name, variable.Type, variable.docstring[:text])
  end

  func_stmt = db.prepare("INSERT INTO functions (file_id, name, type, return, docstring) VALUES (#{file_id}, ?, ?, ?, ?)")
  args_stmt = db.prepare("INSERT INTO arguments (func_id, name, type, flow, docstring) VALUES (?, ?, ?, ?, ?)")
  fargs_stmt = db.prepare("UPDATE functions SET arguments = ? WHERE id = ?")
  tree.functions.each do |function|
    print "Found function #{function.prototype[:name]} with return type #{function.prototype[:type]}\n" if options[:verbose]

    prototype = function.prototype.merge(function.docstring)
    if function.documented?
      prototype[:arguments] = Utils.merge(prototype[:params], prototype[:arguments])
      prototype.delete(:params)
    end

    func_stmt.execute(prototype[:name], prototype[:type], prototype[:return], prototype[:text])
    func_id = db.last_insert_row_id

    args = []
    prototype[:arguments].each do |arg|
      args_stmt.execute(func_id, arg[:name], arg[:type], arg[:flow], arg[:description])
      args << db.last_insert_row_id
    end
    fargs_stmt.execute(args.join("|"), func_id)
  end

  includes = []
  defines_stmt = db.prepare("INSERT INTO defines (file_id, name, value, docstring) VALUES (#{file_id}, ?, ?, ?)")
  tree.directives.each do |directive|
    if directive.include?
      includes << directive.includes
    elsif directive.define?
      defines_stmt.execute(directive.defines[0], directive.defines[1], directive.docstring[:text])
    end
  end
  db.execute("UPDATE files SET includes = ? WHERE id = ?", includes.join("|"), file_id)

  typedef_stmt = db.prepare("INSERT INTO typedefs (file_id, value, name, docstring) VALUES (#{file_id}, ?, ?, ?)")
  tree.typedefs.each do |typedef|
    typedef_stmt.execute(typedef.from, typedef.to, typedef.docstring[:text])
  end
end
