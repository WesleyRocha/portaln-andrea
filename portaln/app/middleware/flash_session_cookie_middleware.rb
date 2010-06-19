require 'rack/utils'

class FlashSessionCookieMiddleware
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      req = Rack::Request.new(env)
      params = req.params
      key = params['session_key']
                       
      unless key.nil?    
        env['HTTP_COOKIE'] = "#{@session_key}=#{key}".freeze
      end
    end
    
    @app.call(env)
  end
end