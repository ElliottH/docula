class Dir
  ##
  ## Recurses through the directory hierarchy below path and executes the given
  ## block on every file _and_ folder.
  ##
  def self.recurse(path, &block)
    Dir.foreach(path) do |entry|
      next if (entry == '.' || entry == '..')

      full_path = File.join(path, entry)
      yield full_path

      if File.directory?(full_path)
        recurse(full_path, &block)
      end
    end
  end
end

class String
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end

  def para
    "<p>#{split("\n\n").join('</p><p>')}</p>"
  end
end
