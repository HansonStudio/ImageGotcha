Pod::Spec.new do |s|
  s.name             = 'HSPhotoKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of HSPhotoKit.'
  s.description      = 'HSPhotoKit'

  s.homepage         = 'https://github.com/zyphs21/HSPhotoKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zyphs21' => 'hansonzyp@gmail.com' }
  s.source           = { :git => 'https://github.com/zyphs21/HSPhotoKit.git', :tag => s.version.to_s }
  s.source_files     = 'HSPhotoKit/HSPhotoKit/*.swift','HSPhotoKit/HSPhotoKit/**/*.swift','HSPhotoKit/HSPhotoKit/**/**/*.swift', 'HSPhotoKit/HSPhotoKit/PhotoBrowser/*.png'
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  
  s.dependency 'Kingfisher/Core'
  s.dependency 'KingfisherWebP'

end
