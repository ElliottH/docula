require 'lib/output'

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
    files_html = header("Files") << "<body>\n"
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
    file_html = header(row['path']) << "<body>\n"
    file_html << "<div id=\"header\">\n"
    file_html << "<h1>#{row['path']}</h1>\n"
    file_html << "<ul id=\"links\">\n"
    file_html << "<li><a href=\"#description\">description</a></li>\n"
    file_html << "<li><a href=\"#defines\">#defines</a></li>\n"
    file_html << "<li><a href=\"#typedefs\">typedefs</a></li>\n"
    file_html << "<li><a href=\"#functions\">functions</a></li>\n"
    file_html << "</ul></div><hr />"
    file_html << "<div id=\"summary\">\n<h2>Summary</h2>\n"
    file_html << "#{row['docstring'].split("\n")[0]}\n</div>\n<hr />"

    includes_html(row)
    file_html << defines_html(row['id'])
    file_html << typedefs_html(row['id'])
    file_html << functions_overview_html(row['id'], row['path'])

    file_html << "<hr />\n<h2 id=\"description\">Description</h2>\n"
    file_html << "#{row['docstring']}"

    file_html << variables_html(row['id'])
    file_html << "<hr />\n<h2>Function Documentation</h2>\n"
    file_html << functions_html(row['id'], row['path'])
  end

  def includes_html(row)
  end

  def defines_html(row)
    if defines(row).count > 0
      html = "<table id=\"defines\" class=\"defs\">\n"
      html << "<thead><th colspan=\"2\">#defines</th></thead>\n<tbody>\n"

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
      html = "<table id=\"typedefs\" class=\"defs\">\n"
      html << "<thead><th colspan=\"2\">Typedefs</th></thead>\n<tbody>\n"

      typedefs(row).each do |typedef|
        html << row_with_id("t#{typedef['id']}", typedef['value'], typedef['name'])
          html << row("", typedef['docstring'])
      end

      html << "</tbody></table>\n"
    else
      ""
    end
  end

  def variables_html(row)
    if variables(row).count > 0
      ""
    else
      ""
    end
  end

  def functions_overview_html(row, path)
    if functions(row).count > 0
      html = "<table id=\"functions\" class=\"defs\">\n"
      html << "<thead><th colspan=\"2\">Functions</th></thead>\n<tbody>\n"

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
      html << "<span class=\"arguments\">Arguments:\n<dl>"

      html << arguments(function['id']).map do |argument|
        "<dt>#{argument['name']}</dt>"
        "<dd><span class=\"flow\">#{argument['flow']}</span>"
        "#{argument['docstring']}</dd>"
      end.join("\n")

      html << "</dl></span>"
      html << "<span class=\"returns\">Returns:\n#{function['return']}</span>"
      html << "</div>"
    end.join("\n")
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
      #href = Pathname.new(info['path']).relative_path_from(Pathname.new(current_path)).to_s
      href << ".html#"
      href << (info['define'] ? "d" : "t")
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

  def link(link, contents)
    "<a href=\"#{link}\">#{contents}</a>"
  end

  def header(title)
    <<-eos.unindent
      <html>
        <head>
          <link rel=\"stylesheet\" href=\"style.css\" type=\"text/css\" />
          <title>#{title}</title>
        </head>
    eos
  end

  @@stylesheet = <<-eos.unindent
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
    table {

    }
    table th {
      width: 100%;
      border-bottom: 1px solid black;
    }
    table.defs {
      width: 100%;
      border: 1px solid black;
      margin-bottom: 3em;
    }
    table.defs tbody tr td:first-child {
      text-align: right;
    }
    table.defs tbody tr:nth-child(even) {
      color: #555;
    }
    span.docstring, span.arguments, span.returns {
      display: block;
    }
  eos
end
