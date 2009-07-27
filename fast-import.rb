#! /usr/bin/env ruby
require 'digest/sha1'

last_mark = nil
$author = 'Scott Chacon <schacon@example.com>'

$marks = []
def convert_dir_to_mark(dir)
  if !$marks.include?(dir)
    $marks << dir
  end
  ($marks.index(dir) + 1).to_s
end

def convert_dir_to_date(dir)
  if dir == 'current'
    return Time.now().to_i
  else
    dir = dir.gsub('back_', '')
    (year, month, day) = dir.split('_')
    return Time.local(year, month, day).to_i
  end
end

def export_data(string)
  print "data #{string.size}\n#{string}"
end

def inline_data(file, code = 'M', mode = '644')
  content = File.read(file)
  puts "#{code} #{mode} inline #{file}"
  export_data(content)
end

def print_export(dir, last_mark)
  mark = convert_dir_to_mark(dir)
  date = convert_dir_to_date(dir)
  
  # print the import information
  puts 'commit refs/heads/master'
  puts 'mark :' + mark
  puts "committer #{$author} #{date} -0700"
  export_data('imported from ' + dir)
  puts 'from :' + last_mark if last_mark

  puts 'deleteall'
  Dir.glob("**/*").each do |file|
    next if !File.file?(file)
    inline_data(file)
  end

  return mark
end

# loop through the directories
Dir.chdir(ARGV[0]) do
  Dir.glob("*").each do |dir|
    next if File.file?(dir)

    # move into the target directory
    Dir.chdir(dir) do 
      last_mark = print_export(dir, last_mark)
    end
  end
end