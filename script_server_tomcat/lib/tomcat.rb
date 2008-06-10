require 'yajb/jbridge'
require 'webrick/httputils'
require 'cgi'
require 'stringio'

class CGI #:nodoc:
  def stdinput
    @stdin || $stdin
  end
  
  def env_table
    @env_table || ENV
  end
  
  def initialize(type = "query", table = nil, stdin = nil)
    @env_table, @stdin = table, stdin
    extend QueryExtension
    @multipart = false
    initialize_query()  # set @params, @cookies
    @output_cookies = nil
    @output_hidden = nil
  end
end

include JavaBridge
  
# TODO how likely is this to come along and bite us should we ever want to do
# *other* YAJB stuff later?
if !defined?(JBRIDGE_OPTIONS) then JBRIDGE_OPTIONS = {} end

class TomcatServer
  @@tomcat_home = nil
  
  def self.create(config = {})
    @@tomcat_home = config[:tomcat_home] || File.join(File.expand_path(RAILS_ROOT),RAILS_ROOT,'vendor','tomcat-5.5.17')
    classpath = "$CLASSPATH:"
    classpath << Dir["#{File.join(@@tomcat_home, 'lib')}/*.jar"].join(':')

    JBRIDGE_OPTIONS[:classpath] = "#{classpath}"
    #JBRIDGE_OPTIONS[:jvm_log_level] = 'debug'
    #JBRIDGE_OPTIONS[:bridge_log] = true
    at_exit { JavaBridge.break_bridge }
    TomcatServer.new
  end
  
  def self.is_ready?
    !@@tomcat_home.nil?
  end
  
  def initialize
    if TomcatServer.is_ready? 
      %w(org.apache.catalina.*
        org.apache.catalina.logger.*
        org.apache.catalina.users.*
        org.apache.catalina.realm.MemoryRealm
        org.apache.catalina.startup.Embedded
        org.apache.catalina.core.StandardWrapper
        org.apache.catalina.core.StandardWrapperFacade
        javax.xml.transform.ErrorListener
        javax.servlet.http.HttpServlet
        javax.servlet.http.HttpServletRequest
        java.lang.Class).each { |x| jimport x }
     @tomcat_server = nil
    end
  end
  
  def start_up_server
    if @tomcat_server.nil?
      mbedTC5 = :Embedded.jnew
      memRealm = :MemoryRealm.jnew
      mbedTC5.setRealm(memRealm)
      baseEngine = mbedTC5.createEngine
      baseEngine.setName('railsEngine')
      baseEngine.setDefaultHost('railsHost')
      baseHost = mbedTC5.createHost('railsHost', File.join(@@tomcat_home,'webapps'))
  		baseEngine.addChild(baseHost)
      rootCtx = mbedTC5.createContext('', File.join(File.expand_path(RAILS_ROOT),'public'))
      
      # This is what rootCtx.createWrapper would do....
      the_rails_servlet_wrapper = RailsServletWrapper.create
      rootCtx.findInstanceListeners().each do |il_name|
        the_rails_servlet_wrapper.addInstanceListener(:Class.jclass.forName(il_name).newInstance)
      end
      rootCtx.findWrapperLifecycles().each do |wlc_name|
        the_rails_servlet_wrapper.addLifecycleListener(:Class.jclass.forName(wl_name).newInstance)
      end
      rootCtx.findWrapperListeners().each do |wl_name|
        the_rails_servlet_wrapper.addLifecycleListener(:Class.jclass.forName(wl_name).newInstance)
      end
      the_rails_servlet_wrapper.setServletName('the_rails_servlet')
      rootCtx.addChild(the_rails_servlet_wrapper)
      rootCtx.addServletMapping('/*','the_rails_servlet')
      rootCtx.addWelcomeFile('index.html')
      
    	baseHost.addChild(rootCtx)
      appCtx = mbedTC5.createContext('/manager', File.join(@@tomcat_home,'webapps','manager'))
      appCtx.setPrivileged(true)
      baseHost.addChild(appCtx)
      mbedTC5.addEngine(baseEngine)
    
      httpConnector = mbedTC5.createConnector(nil, 8080, false)
      mbedTC5.addConnector(httpConnector)
      begin
        mbedTC5.start()
      rescue JavaBridge::JException => uh_oh
        if uh_oh.klass == 'org.apache.catalina.LifecycleException'
          fileLog.log('Startup failed due to tomcat lifecyclexception')
  				fileLog.log(uh_oh.getMessage())
  			else
          fileLog.log("Startup failed for some other reason: #{uh_oh.klass}")
          fileLog.log(uh_oh.getMessage())
  			end
        @tomcat_server = nil
      else
        @tomcat_server = mbedTC5
        @rails_wrapper = the_rails_servlet_wrapper
        at_exit { mbedTC5.stop; the_rails_servlet_wrapper.dispose; }
      end
    end
    nil
  end
  
  class RailsServletWrapper
    def self.create()
      instance = jextend :StandardWrapper
      instance.extend InstanceMethods
      instance.__init(RailsServlet.create)
      instance
    end
    
    module InstanceMethods
      def __init(servlet)
        @instance = servlet
        @class_load_time = 0
        @load_time = 0
        jdef :loadServlet do
          unless (@instance.servlet_init_called?)
            t1 = :System.jclass.currentTimeMillis()
            @class_load_time = :System.jclass.currentTimeMillis() - t1
            self.getInstanceSupport.fireInstanceEvent(:InstanceEvent.jclass.BEFORE_INIT_EVENT, @instance)
            @instance.init(:StandardWrapperFacade.jnew(self))
            self.getInstanceSupport.fireInstanceEvent(:InstanceEvent.jclass.AFTER_INIT_EVENT, @instance)
            fireContainerEvent("load", self)
            @load_time = :System.jclass.currentTimeMillis() - t1
          end
          @instance
        end
        jdef :getClassLoadTime do @class_load_time; end
        jdef :getLoadTime do @load_time; end
      end
      
      def dispose
        @instance.dispose unless @instance.nil?
        junlink self
      end
    end
  end
  
  class RailsServlet
    # With gratuitous use of webrick_server by Florian Gross
    def self.create()
      instance = jextend :HttpServlet
      instance.extend InstanceMethods
      instance.__init()
      instance
    end
    
    module InstanceMethods
      def __init()
        @servlet_init_called = false
        jdef :service do |req, res| 
          do_service(req, res)
        end
      end
      
      def do_service (req, res)
        begin
          path = req.getPathInfo
          if path =~ /\/$/
            try_paths = ["#{path}index.html", path]
          elsif path =~ /[^\.html]$/
            try_paths = ["#{path}.html", path]
          else
            try_paths = [path]
          end
          puts "#{try_paths.inspect}"
          the_file_path = try_paths.find do |try_path| 
            no_dot_dot_path = File.expand_path(File.join(File.expand_path(RAILS_ROOT),'public', try_path))
            if no_dot_dot_path =~ %r{^#{File.expand_path(File.join(File.expand_path(RAILS_ROOT),'public'))}}
              File.exist?(no_dot_dot_path) and not FileTest.directory? no_dot_dot_path
            else
              false
            end
          end
          if the_file_path.nil?
            data = StringIO.new
            cgi_vars = build_cgi_vars(req)
            Dispatcher.dispatch(
              CGI.new("query", cgi_vars, get_request_body(req)), 
              ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS, 
              data
            )
          
            header, body = extract_header_and_body(data)
          
            assign_status(res, header)
            header.each { |key, val| res.setHeader(key, val.join(", ")) }

            writer = res.getOutputStream
            tmp = [:t_int1]
            body.each_byte {|byte| tmp << byte}
            writer.write(tmp,0,tmp.length-1)
            writer.close
          else
            real_file_path = File.expand_path(File.join(File.expand_path(RAILS_ROOT),'public',the_file_path))
            st = File::stat(real_file_path)
            mtime = st.mtime
            res.setHeader('etag', sprintf("%x-%x-%x", st.ino, st.size, st.mtime.to_i))
            mtype = WEBrick::HTTPUtils::mime_type(real_file_path, WEBrick::HTTPUtils::DefaultMimeTypes)
            res.setContentType(mtype)
            res.setHeader('content-length', "#{st.size}")
            res.setHeader('last-modified', "#{mtime.httpdate}")
            File.open(real_file_path, 'rb') do |file|
              #this is bound to be slow....
              writer = res.getOutputStream
              tmp = [:t_int1]
              file.read.each_byte {|byte| tmp << byte}
              writer.write(tmp,0,tmp.length-1)
            end
          end
        rescue Object => e
          puts "#{e.inspect}"
          puts e.backtrace.join("\n") if e.respond_to? :backtrace
          raise e
        end
      end
      
      def assign_status(res, header)
        if /^(\d+)/ =~ header['status'][0]
          puts "status = '#{$1.to_i}', #{$1.to_i.class}"
          res.setStatus($1.to_i)
          header.delete('status')
        end
      end
      
      def get_request_body(req)
        if req.getContentLength > 0
          body = ""
          #reader = req.getInputStream
          #tmp = [:t_int1] + [0]*req.getContentLength
          #while (read_count = reader.read(tmp,0,req.getContentLength)) != -1
          #  puts "read #{read_count} bytes"
          #  puts "they are #{tmp[0..read_count].inspect}"
          #  puts "packed = #{tmp.pack('c'*read_count)}"
          #  body << tmp.pack('c'*read_count)
          #end
          reader = req.getReader
          while not (line = reader.readLine).nil?
            #puts "read line = #{line.inspect}"
            body << line
          end
          StringIO.new(body)
        else
          return StringIO.new('')
        end
      end
      
      def extract_header_and_body(data)
        data.rewind
        data = data.read

        raw_header, body = *data.split(/^[\xd\xa]+/on, 2)
        header = WEBrick::HTTPUtils::parse_header(raw_header)

        return header, body
      end
      
      def build_cgi_vars(request)
        vars = {}
        vars['AUTH_TYPE'] = request.getAuthType()
        vars['CONTENT_LENGTH'] = "#{request.getContentLength()}"
        vars['CONTENT_TYPE'] = request.getContentType()
        vars['DOCUMENT_ROOT'] = self.getServletContext().getRealPath("/") 
        vars['PATH_INFO'] = request.getPathInfo()
        vars['PATH_TRANSLATED'] = request.getPathTranslated()
        vars['QUERY_STRING'] = request.getQueryString()
        vars['REMOTE_ADDR'] = request.getRemoteAddr()
        vars['REMOTE_HOST'] = request.getRemoteHost()
        vars['REMOTE_USER'] = request.getRemoteUser()
        vars['REQUEST_METHOD'] = request.getMethod()
        vars['SCRIPT_NAME'] = request.getServletPath()
        vars['SERVER_NAME'] = request.getServerName()
        vars['SERVER_PORT'] = "#{request.getServerPort()}"
        vars['SERVER_PROTOCOL'] = request.getProtocol()
        vars['SERVER_SOFTWARE'] = self.getServletContext().getServerInfo()
        
        names_enum = request.getHeaderNames
        while names_enum.hasMoreElements 
          hn = names_enum.nextElement
          next if /^content-type$/i =~ hn
          next if /^content-length$/i =~ hn
          name = "HTTP_" + hn
          name.gsub!(/-/o, "_")
          name.upcase!
          vars[name] = request.getHeader(hn)
        end
        
        #puts "CGI Vars = #{vars.inspect}"
        vars
      end
      
      def init(config)
        super(config)
        @servlet_init_called = true
      end
      
      def servlet_init_called?
        @servlet_init_called
      end
      
      def dispose
        junlink self
      end
    end
  end
end