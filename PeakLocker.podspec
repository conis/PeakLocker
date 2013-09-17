Pod::Spec.new do |s|
  s.name         = "PeakLocker"
  s.version      = "0.0.1"
  s.summary      = "简单的用户登陆模块，含登陆密码设置，密码修改，登陆，并且可以切换模式解锁与密码解锁两种方式."
  s.homepage     = "https://github.com/conis/PeakLocker"
  s.license      = 'MIT'
  s.author       = { "Conis" => "conis.yi@gmail.com" }
  s.source       = { :git => "/Volumes/Files/Cloud/Dropbox/git-repos/PeakForm.git/", :master => "branch"}
  s.platform     = :ios, '5.0'
  s.source_files = 'PeakLocker/*.{h,m}'
  s.framework  = 'UIKit'
  s.requires_arc = true
end
