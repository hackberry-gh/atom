require "i18n"
require "ip_country"

module Pubs
  module Api
      module Locale

        LNG_EXP_PATH = /^\/[a-z]{2}\-[A-Z]{2}\/|^\/[a-z]{2}\-[A-Z]{2}$|^\/[a-z]{2}\/|^\/[a-z]{2}$/
        LNG_EXP_HTTP = /[a-z]{2}\-[A-Z]{2}|[a-z]{2}/

        private

        # Hash to collect all language related info
        def language_info
          { current: ::I18n.locale, path: path_locale,
            browser: browser_locale, country: country_locales }
        end

        # ======================
        # Language Detection
        # ======================

        # Set current locale
        def set_locale
          ::I18n.locale = locale
        end

        # Set locale by precedence path, browser, country, default
        def locale
          params ||= env['params'] || {}
          return params.try(:[],"locale") if locale_available?(params.try(:[],"locale").try(:to_sym))

          return path_locale      if locale_available?(path_locale)
          
          unless country_locales.nil?            
            country_locales.each do |country_locale|
              return country_locale if locale_available? country_locale
            end 

            country_locales.each do |country_locale|
              country_locale = country_locale.split("-").first.to_sym
              return country_locale if locale_available? country_locale
            end 
          end

          return browser_locale   if locale_available? browser_locale

          ::I18n.default_locale
        end

        # Extract locale from request path
        def path_locale
          if path_locale = env['REQUEST_PATH'].scan(LNG_EXP_PATH).first
            path_locale.gsub("/","").to_sym
          end
        end

        # Extract locale from accept language header
        def browser_locale
          env['HTTP_ACCEPT_LANGUAGE'].scan(LNG_EXP_HTTP).first.to_sym unless env['HTTP_ACCEPT_LANGUAGE'].nil?
        end

        # Get all spoken languages in a country sorted by speakers count
        def country_locales
          country_info ? country_info[:languages].split(",") : []
        end

        # Check if ::I18n has locale
        def locale_available? locale
          ::I18n.available_locales.include?(locale)
        end

        # ======================
        # Ip to Country
        # ======================

        # Detailed country info
        def country_info
          begin
            IPCountry.info(remote_ip)
          rescue
            nil
          end
        end

        # Client's IP4 Address
        # Stolen from Rack::Request
        def remote_ip
          if addr = env['HTTP_X_FORWARDED_FOR']
            (addr.split(',').grep(/\d\./).first || env['REMOTE_ADDR']).to_s.strip
          else
            env['REMOTE_ADDR']
          end
        end
        


    end
  end
end