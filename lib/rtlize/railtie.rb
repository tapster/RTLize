require 'rtlize/helpers'
require 'rtlize/rtl_processor'

module Rtlize
  class Railtie < ::Rails::Railtie
    config.rtlize = ActiveSupport::OrderedOptions.new
    config.rtlize.rtl_selector = Rtlize.rtl_selector
    config.rtlize.rtl_locales  = Rtlize.rtl_locales

    initializer "rtlize.railtie", :after => "sprockets.environment" do |app|
      # Support Sprockets 4
      if app.assets.respond_to?(:register_transformer)
        app.assets.register_mime_type 'text/css', extensions: ['.css'], charset: :css
        app.assets.register_postprocessor 'text/css', 'text/css', Rtlize::RtlProcessor
      end

      # Support Sprockets 2, 3
      if app.assets.respond_to?(:register_engine)
        args = ['.css', Rtlize::RtlProcessor]
        args << { mime_type: 'text/css', silence_deprecation: true } if Sprockets::VERSION.start_with?("3")
        app.assets.register_engine(*args)
      end

      Rtlize.rtl_selector = config.rtlize.rtl_selector
      Rtlize.rtl_locales  = config.rtlize.rtl_locales
    end
  end
end
