# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

target 'DailyRecord' do
    pod 'ReactiveObjC'
    pod 'YYKit', '~> 1.0.4'
    pod 'Masonry', '~> 1.1.0'
    pod 'PINCache'
  use_frameworks!

end


#Post Install script to avoid dependency mismatch
  post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end

