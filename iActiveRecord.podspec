Pod::Spec.new do |s|
  s.name     = 'iActiveRecord'
  s.version  = '1.3.3'
  s.license  = 'MIT'
  s.summary  = 'ActiveRecord for iOS without CoreData.'
  s.homepage = 'https://github.com/AlexDenisov/iActiveRecord'
  s.description = %{
    ActiveRecord for iOS without CoreData. Only SQLite.
    For more details check Wiki on Github.
  }
  s.author   = { 'Alex Denisov' => '1101.debian@gmail.com' }
  s.source   = { :git => 'git://github.com/AlexDenisov/iActiveRecord.git', :tag => s.version.to_s}
  s.platform = :ios
  s.source_files = 'iActiveRecord/*.{h,m}', 'iActiveRecord/deps/*.{c,h}'
  s.library = 'sqlite3'
  s.dependency 'NSData+Base64'
end
