module Nexpose

  # Object that represents administrative credentials to be used
  # during a scan. When retrieved from an existing site configuration
  # the credentials will be returned as a security blob and can only
  # be passed back as is during a Site Save operation. This object
  # can only be used to create a new set of credentials.
  #
  class SiteCredential < Credential
    include XMLUtils


    # Security blob for an existing set of credentials
    attr_accessor :blob
    # The service for these credentials.
    attr_accessor :service
    # The host for these credentials.
    attr_accessor :host
    # The port on which to use these credentials.
    attr_accessor :port
    # The password
    attr_accessor :password
    # The realm for these credentials
    attr_accessor :realm
    # When using httpheaders, this represents the set of headers to pass
    # with the authentication request.
    attr_accessor :headers
    # When using htmlforms, this represents the tho form to pass the
    # authentication request to.
    attr_accessor :html_forms
    # The type of privilege escalation to use (sudo/su)
    attr_accessor :priv_type
    # The userid to use when escalating privileges (optional)
    attr_accessor :priv_username
    # The password to use when escalating privileges (optional)
    attr_accessor :priv_password
    # The authentication type to use with SNMP v3 credentials
    attr_accessor :auth_type
    # The privacy/encryption type to use with SNMP v3 credentials
    attr_accessor :privacy_type
    # The privacy/encryption pass phrase to use with SNMP v3 credentials
    attr_accessor :privacy_password

    # Permission elevation type. See Nexpose::Credential::ElevationType.
    attr_accessor :privilege_type
    # The User ID or Username
    attr_accessor :username
    alias :userid :username
    alias :userid= :username=


    def self.for_service(service, user, password, realm = nil, host = nil, port = nil)
      cred = new
      cred.service = service
      cred.username = user
      cred.password = password
      cred.realm = realm
      cred.host = host
      cred.port = port
      cred
    end

    # Sets privilege escalation credentials. Type should be either sudo/su.
    def add_privilege_credentials(type, username, password)
      @priv_type = type
      @priv_username = username
      @priv_password = password
    end

    def add_snmpv3_credentials(auth_type, privacy_type, privacy_password)
      @auth_type = auth_type
      @privacy_type = privacy_type
      @privacy_password = privacy_password
    end

    def self.parse(xml)
      cred = new
      cred.service = xml.attributes['service']
      cred.host = xml.attributes['host']
      cred.port = xml.attributes['port']
      cred.blob = xml.get_text
      cred
    end

    def to_xml
      to_xml_elem.to_s
    end

    def as_xml
      attributes = {}
      attributes['service'] = @service
      attributes['userid'] = @username
      attributes['password'] = @password
      attributes['realm'] = @realm
      attributes['host'] = @host
      attributes['port'] = @port

      attributes['privilegeelevationtype'] = @priv_type if @priv_type
      attributes['privilegeelevationusername'] = @priv_username if @priv_username
      attributes['privilegeelevationpassword'] = @priv_password if @priv_password

      attributes['snmpv3authtype'] = @auth_type if @auth_type
      attributes['snmpv3privtype'] = @privacy_type if @privacy_type
      attributes['snmpv3privpassword'] = @privacy_password if @privacy_password

      xml = make_xml('adminCredentials', attributes, blob)
      xml.add_element(@headers.to_xml_elem) if @headers
      xml.add_element(@html_forms.to_xml_elem) if @html_forms
      xml
    end
    alias_method :to_xml_elem, :as_xml

    include Comparable

    def <=>(other)
      to_xml <=> other.to_xml
    end

    def eql?(other)
      to_xml == other.to_xml
    end

    def hash
      to_xml.hash
    end

  end

  # Object that represents Header name-value pairs, associated with Web Session Authentication.
  #
  class Header
    include XMLUtils

    # Name, one per Header
    attr_reader :name
    # Value, one per Header
    attr_reader :value

    # Construct with name value pair
    def initialize(name, value)
      @name = name
      @value = value
    end

    def as_xml
      attributes = {}
      attributes['name'] = @name
      attributes['value'] = @value

      make_xml('Header', attributes)
    end
    alias_method :to_xml_elem, :as_xml
  end

  # Object that represents Headers, associated with Web Session Authentication.
  #
  class Headers
    include XMLUtils

    # A regular expression used to match against the response to identify authentication failures.
    attr_reader :soft403
    # Base URL of the application for which the form authentication applies.
    attr_reader :webapproot
    # When using HTTP headers, this represents the set of headers to pass with the authentication request.
    attr_reader :headers

    def initialize(webapproot, soft403)
      @headers = []
      @webapproot = webapproot
      @soft403 = soft403
    end

    def add_header(header)
      @headers.push(header)
    end

    def as_xml
      attributes = {}
      attributes['webapproot'] = @webapproot
      attributes['soft403'] = @soft403

      xml = make_xml('Headers', attributes)
      @headers.each do |header|
        xml.add_element(header.to_xml_elem)
      end
      xml
    end
    alias_method :to_xml_elem, :as_xml

  end

  # When using HTML form, this represents the login form information.
  #
  class Field
    include XMLUtils

    # The name of the HTML field (form parameter).
    attr_reader :name
    # The value of the HTML field (form parameter).
    attr_reader :value
    # The type of the HTML field (form parameter).
    attr_reader :type
    # Is the HTML field (form parameter) dynamically generated? If so,
    # the login page is requested and the value of the field is extracted
    # from the response.
    attr_reader :dynamic
    # If the HTML field (form parameter) is a radio button, checkbox or select
    # field, this flag determines if the field should be checked (selected).
    attr_reader :checked

    def initialize(name, value, type, dynamic, checked)
      @name = name
      @value = value
      @type = type
      @dynamic = dynamic
      @checked = checked
    end

    def as_xml
      attributes = {}
      attributes['name'] = @name
      attributes['value'] = @value
      attributes['type'] = @type
      attributes['dynamic'] = @dynamic
      attributes['checked'] = @checked

      make_xml('Field', attributes)
    end
    alias_method :to_xml_elem, :as_xml
  end

  # When using HTML form, this represents the login form information.
  #
  class HTMLForm
    include XMLUtils

    # The name of the form being submitted.
    attr_reader :name
    # The HTTP action (URL) through which to submit the login form.
    attr_reader :action
    # The HTTP request method with which to submit the form.
    attr_reader :method
    # The HTTP encoding type with which to submit the form.
    attr_reader :enctype
    # The fields in the HTML Form
    attr_reader :fields

    def initialize(name, action, method, enctype)
      @name = name
      @action = action
      @method = method
      @enctype = enctype
      @fields = []
    end

    def add_field(field)
      @fields << field
    end

    def as_xml
      attributes = {}
      attributes['name'] = @name
      attributes['action'] = @action
      attributes['method'] = @method
      attributes['enctype'] = @enctype

      xml = make_xml('HTMLForm', attributes)

      fields.each() do |field|
        xml.add_element(field.to_xml_elem)
      end
      xml
    end
    alias_method :to_xml_elem, :as_xml
  end

  # When using HTML form, this represents the login form information.
  #
  class HTMLForms
    include XMLUtils

    # The URL of the login page containing the login form.
    attr_reader :parentpage
    # A regular expression used to match against the response to identify
    # authentication failures.
    attr_reader :soft403
    # Base URL of the application for which the form authentication applies.
    attr_reader :webapproot
    # The forms to authenticate with
    attr_reader :html_forms

    def initialize(parentpage, soft403, webapproot)
      @parentpage = parentpage
      @soft403 = soft403
      @webapproot = webapproot
      @html_forms = []
    end

    def add_html_form(html_form)
      @html_forms << html_form
    end

    def as_xml
      attributes = {}
      attributes['parentpage'] = @parentpage
      attributes['soft403'] = @soft403
      attributes['webapproot'] = @webapproot

      xml = make_xml('HTMLForms', attributes)

      html_forms.each() do |html_form|
        xml.add_element(html_form.to_xml_elem)
      end
      xml
    end
    alias_method :to_xml_elem, :as_xml
  end

  # When using ssh-key, this represents the PEM-format key-pair information.
  class PEMKey
    # TODO
  end
end
