# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'LykkeBlueLife' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

pod 'Alamofire', '~> 4.4'
pod 'AlamofireImage', '~> 3.1'
pod 'Firebase/DynamicLinks'
pod 'Firebase/Core'
pod 'Firebase/Crash'
pod 'Fabric', '~> 1.7.2'
pod 'Crashlytics', '~> 3.9.3'
pod 'TextFieldEffects', '~> 1.3'
pod 'NVActivityIndicatorView', '~> 3.5'
pod 'Toaster', '~> 2.1'
pod 'TwitterCore', '~> 3.0'
pod 'TwitterKit', '~> 3.2'
pod 'RxDataSources', '~> 2.0'
pod 'QRCodeReader.swift', '~> 7.5.1'
pod 'Toast'

  # Pods for LykkeBlueLife

pod 'WalletCore', :path => '../WalletCoreiOS'
  target 'LykkeBlueLifeTests' do
    inherit! :search_paths
    # Pods for testing
  end



end

post_install do |installer_representation|
    installer_representation.pods_project.build_configurations.each do |config|
        if config.name == 'Release.Test' || config.name == 'Debug.Test' || config.name == 'Release.Dev' || config.name == 'Debug.Dev'
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= []
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] |= ['$(inherited)', 'TEST=1']
        end
    end
end
