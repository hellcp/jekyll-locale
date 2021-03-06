# frozen_string_literal: true

module Jekyll
  module Locale
    autoload :Drop,     "jekyll/locale/drop"
    autoload :Document, "jekyll/locale/document"
    autoload :AutoPage, "jekyll/locale/auto_page"
    autoload :Page,     "jekyll/locale/page"
    autoload :Handler,  "jekyll/locale/handler"
    autoload :Identity, "jekyll/locale/identity"
  end
end

require_relative "jekyll/patches/site"
require_relative "jekyll/patches/utils"

require_relative "jekyll/locale/date_time_handler"
require_relative "jekyll/locale/filters"

require_relative "jekyll/locale/mixins/support"
require_relative "jekyll/locale/mixins/helper"

# Enhance Jekyll::Page and Jekyll::Document classes
[Jekyll::Page, Jekyll::Document].each do |klass|
  klass.include Jekyll::Locale::Support
end

Jekyll::Hooks.register :site, :after_reset do |site|
  handler = site.locale_handler
  handler.reset
  I18n.config.enforce_available_locales = false
end

Jekyll::Hooks.register :site, :post_read do |site|
  handler = site.locale_handler
  handler.setup
  handler.read
end

Jekyll::Hooks.register [:pages, :documents], :pre_render do |document, payload|
  handler = document.site.locale_handler
  handler.current_locale = document.locale
  document.setup_hreflangs if document.setup_hreflangs?
  payload["page"]["locale"]    = document.locale || handler.default_locale
  payload["page"]["hreflangs"] = document.hreflangs
  payload["page"]["locale_siblings"] = document.locale_siblings
end
