module PanelsFor
  module Rails
    module PanelsForHelper

      def panels_for(object, &block)
        capture PanelBuilder.new(object, self), &block
      end

      private

      class PanelBuilder
        include ActionView::Helpers
        include FontAwesome::Rails::IconHelper

        attr_accessor :object, :template, :output_buffer

        def initialize(object, template)
          @object = object
          @template = template
        end

        def panel(name, options = {}, &block)
          content = panel_default(name, options, &block)
          options[:collapse] ? panel_group(name, content) : content
        end

        private

        def panel_default(name, options = {}, &block)
          html_options = {}
          html_options[:id] = options.delete(:id) if options.key?(:id)
          html_options.reverse_merge!({ class: 'panel panel-default' })

          content_tag(:div, html_options) do
            concat(panel_heading(name, options))
            concat(panel_body(name, options, &block))
          end
        end

        def panel_group(name, content)
          content_tag(
            :div,
            content,
            class:
            'panel-group',
            id: "#{name.to_s.underscore}_accordian",
            role: 'tablist',
            aria: { multiselectable: 'true' }
          )
        end

        def panel_heading(name, options = {})
          title = prepare_title(name, options)
          expanded = options[:expanded] ? 'true' : 'false'

          if options[:collapse]
            content = link_to(
              title,
              "##{collapse_id(name)}",
              role: 'button',
              data: {
                toggle: 'collapse',
                parent: "##{name.to_s.underscore}_accordian"
              },
              aria: { expanded: expanded, controls: collapse_id(name) }
            )
            content_tag(:div, panel_title(content),
                        class: 'panel-heading',
                        role: 'tab',
                        id: heading_id(name))
          else
            content_tag(:div, class: 'panel-heading') do
              panel_title(title)
            end
          end
        end

        def panel_title(content)
          content_tag(:h4, content, class: 'panel-title')
        end

        def panel_body(title, options = {}, &block)
          content = content_tag(:div, class: 'panel-body') do
            template.capture(&block)
          end

          if options[:collapse]
            panel_body_collapse(title, content, options)
          else
            content
          end
        end

        def panel_body_collapse(title, content, options)
          classes = 'panel-collapse collapse'
          classes << ' in' unless options[:collapsed]
          content_tag(
            :div,
            content,
            id: "collapse_#{title.to_s.underscore}",
            class: classes,
            role: 'tabpanel',
            aria: { labelledby: heading_id(title) }
          )
        end

        def prepare_title(name, options)
          title = options[:title] || name.to_s.titleize
          options[:icon] ? fa_icon(options[:icon], text: title) : title
        end

        def heading_id(title)
          "heading_#{title.to_s.underscore}"
        end

        def collapse_id(title)
          "collapse_#{title.to_s.underscore}"
        end
      end
    end
  end
end
