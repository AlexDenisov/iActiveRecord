Pod::Spec.new do |s|
  s.name     = 'iActiveRecord'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'ActiveRecord for iOS without CoreData.'
  s.homepage = 'https://github.com/AlexDenisov/iActiveRecord'
  s.author   = { 'Alex Denisov' => '1101.debian@gmail.com' }
  s.source   = { :git => 'git://github.com/AlexDenisov/iActiveRecord.git', :tag => '1.0.0' }
  s.platform = :ios
  # A list of file patterns which select the source files that should be
  # added to the Pods project. If the pattern is a directory then the
  # path will automatically have '*.{h,m,mm,c,cpp}' appended.
  #
  # Alternatively, you can use the FileList class for even more control
  # over the selected files.
  # (See http://rake.rubyforge.org/classes/Rake/FileList.html.)
  #
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.library = 'sqlite3'
end
