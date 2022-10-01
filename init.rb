require 'redmine'

require File.expand_path('../lib/redmine_wiki_outdated_page_warning/view_hook', __FILE__)

Redmine::Plugin.register :redmine_wiki_outdated_page_warning do
  name 'Redmine Wiki Outdated Page Warning plugin'
  author 'onozaty'
  description 'A plugin that displays warning on outdated wiki pages.'
  version '1.0.0'
  url 'https://github.com/onozaty/redmine_wiki_outdated_page_warning'
  author_url 'https://github.com/onozaty'

  settings :default => {
    :days => 365,
    :warning_message => 'This page has not been updated in over a year.'
  }, :partial => 'settings/wiki_outdated_page_warning_settings'
end
