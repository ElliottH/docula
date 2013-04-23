require 'docula/output'

require 'fileutils'

class HtmlOutput < Output
  def initialize(db, options)
    super

    Dir.mkdir(options[:output]) unless File.directory? options[:output]

    stylefile = File.join(options[:output], "style.css")
    File.open(
      stylefile, 'w'
    ) { |f| f.write(@@stylesheet) } unless File.exist? stylefile
  end

  def output
    files_html = header("Files", ".") << "<body>\n"
    files_html << "<table><thead><th>Files</th></thead><tbody>"

    files.each do |row|
      files_html << row(
                      link(
                        "#{row['path']}.html",
                        row['path']
                      ),
                      row['docstring'].split("\n\n")[0]
                    )

      file = File.join(@options[:output], "#{row['path']}.html")
      FileUtils.mkdir_p(File.dirname(file))
      File.open(
        file, 'w'
      ) { |f| f.write(file_html(row)) }
    end

    files_html << "</tbody></table></body></html>"
    File.open(
      File.join(@options[:output], "files.html"),
      'w'
    ) { |f| f.write(files_html) }
  end

  def file_html(row)
    file_html = header(row['path'], row['path']) << "<body>\n"
    file_html << "<div id=\"header\">\n"
    file_html << "<h1>#{row['path']}</h1>\n"
    file_html << "<ul id=\"links\">\n"
    file_html << "<li><a href=\"#description\">description</a></li>\n"
    file_html << "<li><a href=\"#defines\">#defines</a></li>\n"
    file_html << "<li><a href=\"#typedefs\">typedefs</a></li>\n"
    file_html << "<li><a href=\"#variables\">variables</a></li>\n"
    file_html << "<li><a href=\"#functions\">functions</a></li>\n"
    file_html << "</ul></div><hr />"

    if row['docstring'] != ""
      file_html << "<div id=\"summary\">\n<h2>Summary</h2>\n"
      file_html << "#{row['docstring'].split("\n")[0]}\n"
      file_html << "<br />#{link("#description", "Read More")}</div>\n"
    end

    file_html << includes_html(row['id'], row['path'])
    file_html << defines_html(row['id'])
    file_html << typedefs_html(row['id'])
    file_html << functions_overview_html(row['id'], row['path'])
    file_html << variables_html(row['id'], row['path'])
    file_html << structs_html(row['id'], row['path'])

    if row['docstring'] != ""
      file_html << "<hr />\n<h2 id=\"description\">Description</h2>\n"
      file_html << "#{row['docstring']}"
    end

    file_html << functions_html(row['id'], row['path'])
  end

  def includes_html(row, path)
    if includes(row).count + other_includes(row).count > 0
      html = "<hr /><h2 id=\"includes\">Includes</h2>\n"
      html << "<ul><li>"

      included = []
      if includes(row).count > 0
        included << includes(row).map do |include|
          link("#{relative(path, include['path'])}.html", include['path'])
        end.join("</li><li>")
      end
      if other_includes(row).count > 0
        included << other_includes(row).map do |include|
          include['path']
        end.join("</li><li>")
      end
      html << included.join("</li><li>")

      html << "</li></ul>"
    else
      ""
    end
  end

  def defines_html(row)
    if defines(row).count > 0
      html = "<hr /><h2 id=\"defines\">Defines</h2>\n"
      html << "<table class=\"defs\">\n"
      html << "<thead><th>Name</th><th>Value</th></thead><tbody>"

      defines(row).each do |define|
        html << row_with_id("d#{define['id']}", define['name'], define['value'])
        html << row("", define['docstring'])
      end

      html << "</tbody></table>\n"
    else
      ""
    end
  end

  def typedefs_html(row)
    if typedefs(row).count > 0
      html = "<hr /><h2 id=\"typedefs\">Typedefs</h2>\n"
      html << "<table class=\"defs\">\n"
      html << "<thead><th>Name</th><th>Value</th></thead><tbody>"

      typedefs(row).each do |typedef|
        html << row_with_id("t#{typedef['id']}", typedef['name'], typedef['value'])
        html << row("", typedef['docstring'])
      end

      html << "</tbody></table>\n"
    else
      ""
    end
  end

  def variables_html(row, path)
    if variables(row).count > 0
      html = "<hr /><h2 id=\"variables\">Variables</h2>\n"
      html << "<table class=\"defs\">\n"
      html << "<thead><th>Type</th><th>Name</th></thead><tbody>"

      variables(row).each do |variable|
        html << row_with_id(
                  "v#{variable['id']}",
                  formatted_type(variable['type'], path),
                  variable['name']
                )
        html << row("", variable['docstring'])
      end

      html << "</tbody></table>\n"
    else
      ""
    end
  end

  def structs_html(id, path)
    "<hr /><h2 id=\"structs\">structs &amp; unions</h2><div id=\"fdefs\">\n" <<
    "<div>" <<
    structs_unions(id).map do |su|
      "<table>" <<
      row_with_id(
        "s#{su['id']}",
        su['su'],
        su['type'],
        "{"
      ) <<
      elements(su['id']).map do |elem|
        row(
          "", "", "",
          formatted_type(elem['type'], path),
          elem['name']
        )
      end.join("\n") <<
      row(
        "", "",
        "}"
      ) <<
      "</table></div>" <<
      su['docstring']
    end.join("\n") <<
    "</div>"
  end

  def functions_overview_html(row, path)
    if functions(row).count > 0
      html = "<hr /><h2 id=\"functions\">Functions</h2>\n"
      html << "<table class=\"defs\">\n<tbody>\n"

      functions(row).each do |function|
        html << "<tr><td>#{formatted_type(function['type'], path)}</td>"
        html << "<td><a href=\"#f#{function['id']}\">#{function['name']}</a>( "

        html << arguments(function['id']).map do |argument|
          "#{argument['type']} #{argument['name']}"
        end.join(", ")

        html << " )</td></tr>"

        if function['docstring']
          html << row("", function['docstring'].split("\n\n")[0])
        else
          html << row()
        end
      end

      html << "</tbody></table>\n"
    else
      ""
    end
  end

  def functions_html(row, path)
    "<hr /><h2 id=\"\">Function Documentation</h2>\n<div id=\"fdefs\">" <<
    functions(row).map do |function|
      html = "<div id=\"f#{function['id']}\"><table><tbody><tr>"
      html << "<td>#{formatted_type(function['type'], path)}</td>"
      html << "<td>#{function['name']}</td>"
      html << "<td>(</td>"

      html << arguments(function['id']).map do |argument|
        "<td>#{formatted_type(argument['type'], path)}</td><td>#{argument['name']}</td>"
      end.join("</tr>\n<tr><td></td><td></td><td></td><td></td><td></td>")

      html << "</tr>\n<tr><td></td><td></td><td>)</td></tr></tbody></table>"
      html << "<span class=\"docstring\">#{function['docstring']}</span>"

      if arguments(function['id']).count > 0
        html << "<br /><span class=\"arguments\"><span class=\"bf\">Arguments:</span>\n<dl>"

        html << arguments(function['id']).map do |argument|
          <<-eos.unindent
          <dt>#{argument['name']}</dt>
          <dd><span class=\"flow\">#{argument['flow']}</span>
          #{argument['docstring']}</dd>
          eos
        end.join("\n")

        html << "</dl></span>"
      end

      if function['return']
        html << "<br /><span class=\"returns\"><span class=\"bf\">Returns:</span>\n#{function['return']}</span>"
      end

      if (equiv = equiv_function(function['id']))
        html << "<span class=\"also\"><span class=\"bf\">See also:</span>\n"
        html << equiv.map { |e| func_by_id(e, path) }.join(', ') << "</span>"
      end
      html << "</div>"
    end.join("\n") << "</div>"
  end

  def row(*entries)
    row_with_id("", entries)
  end

  def relative(from, to)
    fromp, top = Pathname.new(from), Pathname.new(to)
    top.relative_path_from(fromp.dirname).to_s
  end

  def formatted_type(type, current_path)
    info = type(type)
    if info
      href = relative(current_path, info['path'])
      href << ".html#"
      if info["'typedef'"] == 'define'
        href << 'd'
      elsif info["'typedef'"] == 'typedef'
        href << 't'
      elsif info["'typedef'"] == 'struct'
        href << 's'
      end
      href << info['id'].to_s
      link(href, type)
    else
      type
    end
  end

  def row_with_id(id, *entries)
    if entries == []
      "<tr id=\"#{id}\"></tr>"
    else
      "<tr id=\"#{id}\"><td>#{entries.join("</td><td>")}</td></tr>\n"
    end
  end

  def func_by_id(id, current_path)
    func = function(id)
    link(
      "#{relative(current_path, func['path'])}.html#f#{func['id']}",
      "#{File.basename(func['path'])}##{func['name']}"
    )
  end

  def link(link, contents)
    "<a href=\"#{link}\">#{contents}</a>"
  end

  def header(title, path)
    <<-eos.unindent
      <html>
        <head>
          <link rel=\"stylesheet\" href=\"#{relative(path, "style.css")}\" type=\"text/css\" />
          <title>#{title}</title>
        </head>
    eos
  end

  @@base03  = "#002b36"
  @@base02  = "#073642"
  @@base01  = "#586e75"
  @@base00  = "#657b83"
  @@base0   = "#839496"
  @@base1   = "#93a1a1"
  @@base2   = "#eee8d5"
  @@base3   = "#fdf6e3"
  @@yellow  = "#b58900"
  @@orange  = "#cb4b16"
  @@red     = "#dc322f"
  @@magenta = "#d33682"
  @@violet  = "#6c71c4"
  @@blue    = "#268bd2"
  @@cyan    = "#2aa198"
  @@green   = "#859900"

  @@stylesheet = <<-eos.unindent
    html * {
      color-profile: sRGB;
      rendering-intent: auto;
    }
    html {
      background-color: #{@@base3};
      color: #{@@base02};
      * {
        color: #{@@base02};
      }
    }
    h1,h2,h3,h4,h5,h6 {
      color: #{@@base02};
      border-color: #{@@base00};
    }
    a, a:active {
      color: #{@@blue};
    }
    a:visited {
      color: #{@@violet};
    }
    div#header {
      width: 100%;
      text-align: center;
    }
    div#header ul {
      list-style-type: none;
      padding: 0;
    }
    div#header li {
      display: inline;
      margin: 0 0.5em;
    }
    div#fdefs div {
      margin-bottom: 1em;
      padding: 0.25em;
    }
    div#fdefs div:nth-child(even) {
      background-color: #{@@base2};
    }
    table {
      color: #{@@base02};
    }
    table.defs {
      width: 100%;
      margin-left: auto;
      margin-right: auto;
      margin-bottom: 3em;
      border-collapse:collapse;
    }
    table.defs th {
      text-align: left;
      padding-bottom: 1em;
    }
    table.defs th:first-child{
      text-align: right;
      padding-right: 1em;
    }
    table.defs tr {
      margin: 0;
      padding: 0;
    }
    table.defs tbody tr td:first-child {
      text-align: right;
      padding-right: 1em;
    }
    table.defs tbody tr:nth-child(even) {
      color: #{@@base01};
    }
    table.defs tbody tr:nth-child(3n), table.defs tbody tr:nth-child(4n) {
      background-color: #{@@base2};
      border-color: #{@@blue};
      border-width: 0 1 1 0;
    }
    span.docstring, span.arguments, span.returns, span.also {
      display: block;
    }
    span.bf {
      font-weight: bold;
    }
    span.flow {
      color: #{@@base1}
    }
    hr {
      border: 0;
      height: 0;
      border-top: 1px solid rgba(0, 0, 0, 0.1);
      border-bottom: 1px solid rgba(255, 255, 255, 0.3);
    }
  eos
end
