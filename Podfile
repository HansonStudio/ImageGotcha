platform :ios, '11.0'
use_frameworks!

def shared_pods
    pod 'Reusable'
    pod 'SnapKit'
    pod 'Blueprints'
    pod 'HSPhotoKit', :path => 'HSPhotoKit/.'
end

target 'ImageGotcha' do
    shared_pods
end

target 'ImageGotchaAction' do
    shared_pods
end


# To Fix "UIApplication 'shared' is unavailable in application extensions for Mac Catalyst"
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
        end
    end
end
