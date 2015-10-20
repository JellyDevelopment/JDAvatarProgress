#
# Be sure to run `pod lib lint JDAvatarProgress.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JDAvatarProgress"
  s.version          = "1.0.2"
  s.summary          = "Easy customizable avatar image asynchronously with progress bar animated"
  s.description      = "Easy customizable avatar image asynchronously with progress bar animated. Enjoy it!"

  s.homepage         = "https://github.com/JellyDevelopment/JDAvatarProgress.git"
  s.license          = 'MIT'
  s.author           = { "Juanpe" => "juanpecm@gmail.com" }
  s.source           = { :git => "https://github.com/JellyDevelopment/JDAvatarProgress.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/JuanpeCMiOS'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'QuartzCore'
end
