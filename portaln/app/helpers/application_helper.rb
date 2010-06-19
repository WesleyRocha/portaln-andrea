# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
                                 
  # check_tab?({
  #   :controller1 => [:method1, :method2],
  #   :controller2 => [:method3, :method4, :method5],
  #   :controller3 => :method6,
  #   :controller4 => :all
  # })                        
  #
  # return 'current' if match
  #
  def check_tab?(hash, return_value = 'current')
    
    hash.keys.each do |control|
      methods = hash[control]
      array = (methods.class == Array) ? true : false
      
      unless array
        method = methods
        all = (method == :all) ? true : false
        
        if all
          return (controller_name == control.to_s) ? return_value : ''
        else
          return (controller_name == control.to_s and action_name == method.to_s) ? return_value : ''
        end
        
      else
        
        if controller_name == control.to_s
          
          methods.each do |method|
            if action_name == method.to_s then return return_value end
          end
          
        end
        return ''
        
      end
      
    end
  end
                     
  def small_format(datetime)
    if datetime > Date.today
      return datetime.strftime("%I:%M%p")
    end
    datetime.strftime("%d %b")
  end
  
  # Formata a data no formato brasileiro: dd/mm/YYYY
  def date_format(date)
    if date
     date.strftime("%d/%m/%Y")
    end
  end

  # Formata a data e hora no formato brasileiro: dd/mm/YYYY
  def datetime_format(datetime)
    if datetime
     datetime.strftime("%d/%m/%Y %I:%M%p")
    end
  end     
  
  def time_format(time)
    if time
      time.strftime("%I:%M%p")
    end
  end     
  
  def path_to_resource(source)
    generate_path(source)
  end
  
  def default_img_path
    path_to_resource('images/icons/default_img_capa.png')
  end           
  
  # Recebe um hash {id => mascara}. ex: {:field_1 => '99/99/9999', :field_2 => '(999) 9999-9999'}
  def mask_fields(hash)
    fields = []
    hash.keys.each do |key|
      fields << %Q{
        $("#{'#'+(key.to_s)}").mask("#{hash[key]}");
      }
    end

    %Q{
      <script type="text/javascript">
        jQuery(function($){
          $(document).ready(function(){
            #{fields}
          });
        });
      </script>
    }
  end    
                                          
  private
  def generate_path(source)
    has_request = @controller.respond_to?(:request)
    
    unless source =~ %r{^[-a-z]+://}
      source = "/#{source}" unless source[0] == ?/

      source = rewrite_asset_path(source)

      if has_request
        unless source =~ %r{^#{ActionController::Base.relative_url_root}/}
          source = "#{ActionController::Base.relative_url_root}#{source}"
        end
      end
    end
    
    if source !~ %r{^[-a-z]+://}
      host = compute_asset_host(source)
      
      if has_request && !host.blank? && host !~ %r{^[-a-z]+://}
        host = "#{@controller.request.protocol}#{host}"
      end

      "#{host}#{source}"
    else
      source
    end
    
  end
  
  def compute_asset_host(source)
    if host = ActionController::Base.asset_host
      if host.is_a?(Proc) || host.respond_to?(:call)
        case host.is_a?(Proc) ? host.arity : host.method(:call).arity
        when 2
          request = @controller.respond_to?(:request) && @controller.request
          host.call(source, request)
        else
          host.call(source)
        end
      else
        (host =~ /%d/) ? host % (source.hash % 4) : host
      end
    end
  end
  
end
