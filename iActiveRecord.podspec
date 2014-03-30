Pod::Spec.new do |s|
  s.name     = 'iActiveRecord'
  s.version  = '1.9.2'
  s.license  = 'MIT'
  s.summary  = 'ActiveRecord for iOS without CoreData, only SQLite.'
  s.homepage = 'https://github.com/AlexDenisov/iActiveRecord'
  s.description = %{
    ActiveRecord for iOS without CoreData. Only SQLite.
    For more details check Wiki on Github.
  }
  s.author   = { 'Alex Denisov' => '1101.debian@gmail.com' }
  s.source   = {  :git => 'https://github.com/AlexDenisov/iActiveRecord.git',
                  :tag => s.version.to_s
                }

  s.platform = :ios ,"5.0"
  s.source_files = 'iActiveRecord/**/*.{c,h,m,mm}'
  s.library = 'sqlite3'
  s.requires_arc = true

  s.xcconfig = {
    'OTHER_LDFLAGS' => '-lc++',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SQLITE_CORE SQLITE_ENABLE_UNICODE' 
  }
end
