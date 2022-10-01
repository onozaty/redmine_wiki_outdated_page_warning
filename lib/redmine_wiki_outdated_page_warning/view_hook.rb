module RedmineWikiOutdatedPageWarning

  class ViewHook < Redmine::Hook::ViewListener
    def view_layouts_base_body_bottom(context={})

      return unless context[:controller]
      params = context[:controller].params
      return unless params[:controller] == 'wiki' && params[:action] == 'show'

      return context[:controller].send(:render, {
        :partial => "templates/outdated_warning"
      })

    end
  end
end
