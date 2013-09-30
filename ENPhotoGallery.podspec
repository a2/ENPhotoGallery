Pod::Spec.new do |s|
  s.name         = "ENPhotoGallery"
  s.version      = "0.2.0"
  s.summary      = "An extendable and customizable photo gallery for iOS."
  s.homepage     = "https://github.com/a2/ENPhotoGallery"
  s.license      = 'MIT'
  s.author       = { "Ethan Nguyen" => "thanhnx.605@gmail.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/a2/ENPhotoGallery.git", :tag => "#{s.version}" }
  s.source_files  = 'ENPhotoGallery/*.{h,m}'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 2.0'
end
