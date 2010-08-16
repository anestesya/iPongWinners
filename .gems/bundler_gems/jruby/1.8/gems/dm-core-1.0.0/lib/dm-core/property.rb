module DataMapper
  # = Properties
  # Properties for a model are not derived from a database structure, but
  # instead explicitly declared inside your model class definitions. These
  # properties then map (or, if using automigrate, generate) fields in your
  # repository/database.
  #
  # If you are coming to DataMapper from another ORM framework, such as
  # ActiveRecord, this may be a fundamental difference in thinking to you.
  # However, there are several advantages to defining your properties in your
  # models:
  #
  # * information about your model is centralized in one place: rather than
  #   having to dig out migrations, xml or other configuration files.
  # * use of mixins can be applied to model properties: better code reuse
  # * having information centralized in your models, encourages you and the
  #   developers on your team to take a model-centric view of development.
  # * it provides the ability to use Ruby's access control functions.
  # * and, because DataMapper only cares about properties explicitly defined
  # in
  #   your models, DataMapper plays well with legacy databases, and shares
  #   databases easily with other applications.
  #
  # == Declaring Properties
  # Inside your class, you call the property method for each property you want
  # to add. The only two required arguments are the name and type, everything
  # else is optional.
  #
  #   class Post
  #     include DataMapper::Resource
  #
  #     property :title,   String,  :required => true  # Cannot be null
  #     property :publish, Boolean, :default => false   # Default value for new records is false
  #   end
  #
  # By default, DataMapper supports the following primitive (Ruby) types
  # also called core types:
  #
  # * Boolean
  # * String (default length is 50)
  # * Text (limit of 65k characters by default)
  # * Float
  # * Integer
  # * BigDecimal
  # * DateTime
  # * Date
  # * Time
  # * Object (marshalled out during serialization)
  # * Class (datastore primitive is the same as String. Used for Inheritance)
  #
  # Other types are known as custom types.
  #
  # For more information about available Types, see DataMapper::Type
  #
  # == Limiting Access
  # Property access control is uses the same terminology Ruby does. Properties
  # are public by default, but can also be declared private or protected as
  # needed (via the :accessor option).
  #
  #  class Post
  #   include DataMapper::Resource
  #
  #    property :title, String, :accessor => :private    # Both reader and writer are private
  #    property :body,  Text,   :accessor => :protected  # Both reader and writer are protected
  #  end
  #
  # Access control is also analogous to Ruby attribute readers and writers, and can
  # be declared using :reader and :writer, in addition to :accessor.
  #
  #  class Post
  #    include DataMapper::Resource
  #
  #    property :title, String, :writer => :private    # Only writer is private
  #    property :tags,  String, :reader => :protected  # Only reader is protected
  #  end
  #
  # == Overriding Accessors
  # The reader/writer for any property can be overridden in the same manner that Ruby
  # attr readers/writers can be.  After the property is defined, just add your custom
  # reader or writer:
  #
  #  class Post
  #    include DataMapper::Resource
  #
  #    property :title, String
  #
  #    def title=(new_title)
  #      raise ArgumentError if new_title != 'Luke is Awesome'
  #      @title = new_title
  #    end
  #  end
  #
  # == Lazy Loading
  # By default, some properties are not loaded when an object is fetched in
  # DataMapper. These lazily loaded properties are fetched on demand when their
  # accessor is called for the first time (as it is often unnecessary to
  # instantiate -every- property -every- time an object is loaded).  For
  # instance, DataMapper::Property::Text fields are lazy loading by default,
  # although you can over-ride this behavior if you wish:
  #
  # Example:
  #
  #  class Post
  #    include DataMapper::Resource
  #
  #    property :title, String  # Loads normally
  #    property :body,  Text    # Is lazily loaded by default
  #  end
  #
  # If you want to over-ride the lazy loading on any field you can set it to a
  # context or false to disable it with the :lazy option. Contexts allow
  # multipule lazy properties to be loaded at one time. If you set :lazy to
  # true, it is placed in the :default context
  #
  #  class Post
  #    include DataMapper::Resource
  #
  #    property :title,   String                                    # Loads normally
  #    property :body,    Text,   :lazy => false                    # The default is now over-ridden
  #    property :comment, String, :lazy => [ :detailed ]            # Loads in the :detailed context
  #    property :author,  String, :lazy => [ :summary, :detailed ]  # Loads in :summary & :detailed context
  #  end
  #
  # Delaying the request for lazy-loaded attributes even applies to objects
  # accessed through associations. In a sense, DataMapper anticipates that
  # you will likely be iterating over objects in associations and rolls all
  # of the load commands for lazy-loaded properties into one request from
  # the database.
  #
  # Example:
  #
  #   Widget.get(1).components
  #     # loads when the post object is pulled from database, by default
  #
  #   Widget.get(1).components.first.body
  #     # loads the values for the body property on all objects in the
  #     # association, rather than just this one.
  #
  #   Widget.get(1).components.first.comment
  #     # loads both comment and author for all objects in the association
  #     # since they are both in the :detailed context
  #
  # == Keys
  # Properties can be declared as primary or natural keys on a table.
  # You should a property as the primary key of the table:
  #
  # Examples:
  #
  #  property :id,        Serial                # auto-incrementing key
  #  property :legacy_pk, String, :key => true  # 'natural' key
  #
  # This is roughly equivalent to ActiveRecord's <tt>set_primary_key</tt>,
  # though non-integer data types may be used, thus DataMapper supports natural
  # keys. When a property is declared as a natural key, accessing the object
  # using the indexer syntax <tt>Class[key]</tt> remains valid.
  #
  #   User.get(1)
  #      # when :id is the primary key on the users table
  #   User.get('bill')
  #      # when :name is the primary (natural) key on the users table
  #
  # == Indices
  # You can add indices for your properties by using the <tt>:index</tt>
  # option. If you use <tt>true</tt> as the option value, the index will be
  # automatically named. If you want to name the index yourself, use a symbol
  # as the value.
  #
  #   property :last_name,  String, :index => true
  #   property :first_name, String, :index => :name
  #
  # You can create multi-column composite indices by using the same symbol in
  # all the columns belonging to the index. The columns will appear in the
  # index in the order they are declared.
  #
  #   property :last_name,  String, :index => :name
  #   property :first_name, String, :index => :name
  #      # => index on (last_name, first_name)
  #
  # If you want to make the indices unique, use <tt>:unique_index</tt> instead
  # of <tt>:index</tt>
  #
  # == Inferred Validations
  # If you require the dm-validations plugin, auto-validations will
  # automatically be mixed-in in to your model classes:
  # validation rules that are inferred when properties are declared with
  # specific column restrictions.
  #
  #  class Post
  #    include DataMapper::Resource
  #
  #    property :title, String, :length => 250
  #      # => infers 'validates_length :title,
  #             :minimum => 0, :maximum => 250'
  #
  #    property :title, String, :required => true
  #      # => infers 'validates_present :title
  #
  #    property :email, String, :format => :email_address
  #      # => infers 'validates_format :email, :with => :email_address
  #
  #    property :title, String, :length => 255, :required => true
  #      # => infers both 'validates_length' as well as
  #      #    'validates_present'
  #      #    better: property :title, String, :length => 1..255
  #
  #  end
  #
  # This functionality is available with the dm-validations gem, part of the
  # dm-more bundle. For more information about validations, check the
  # documentation for dm-validations.
  #
  # == Default Values
  # To set a default for a property, use the <tt>:default</tt> key.  The
  # property will be set to the value associated with that key the first time
  # it is accessed, or when the resource is saved if it hasn't been set with
  # another value already.  This value can be a static value, such as 'hello'
  # but it can also be a proc that will be evaluated when the property is read
  # before its value has been set.  The property is set to the return of the
  # proc.  The proc is passed two values, the resource the property is being set
  # for and the property itself.
  #
  #   property :display_name, String, :default => { |resource, property| resource.login }
  #
  # Word of warning.  Don't try to read the value of the property you're setting
  # the default for in the proc.  An infinite loop will ensue.
  #
  # == Embedded Values
  # As an alternative to extraneous has_one relationships, consider using an
  # EmbeddedValue.
  #
  # == Property options reference
  #
  #  :accessor            if false, neither reader nor writer methods are
  #                       created for this property
  #
  #  :reader              if false, reader method is not created for this property
  #
  #  :writer              if false, writer method is not created for this property
  #
  #  :lazy                if true, property value is only loaded when on first read
  #                       if false, property value is always loaded
  #                       if a symbol, property value is loaded with other properties
  #                       in the same group
  #
  #  :default             default value of this property
  #
  #  :allow_nil           if true, property may have a nil value on save
  #
  #  :key                 name of the key associated with this property.
  #
  #  :serial              if true, field value is auto incrementing
  #
  #  :field               field in the data-store which the property corresponds to
  #
  #  :length              string field length
  #
  #  :format              format for autovalidation. Use with dm-validations plugin.
  #
  #  :index               if true, index is created for the property. If a Symbol, index
  #                       is named after Symbol value instead of being based on property name.
  #
  #  :unique_index        true specifies that index on this property should be unique
  #
  #  :auto_validation     if true, automatic validation is performed on the property
  #
  #  :validates           validation context. Use together with dm-validations.
  #
  #  :unique              if true, property column is unique. Properties of type Serial
  #                       are unique by default.
  #
  #  :precision           Indicates the number of significant digits. Usually only makes sense
  #                       for float type properties. Must be >= scale option value. Default is 10.
  #
  #  :scale               The number of significant digits to the right of the decimal point.
  #                       Only makes sense for float type properties. Must be > 0.
  #                       Default is nil for Float type and 10 for BigDecimal
  #
  #  All other keys you pass to +property+ method are stored and available
  #  as options[:extra_keys].
  #
  # == Misc. Notes
  # * Properties declared as strings will default to a length of 50, rather than
  #   255 (typical max varchar column size).  To overload the default, pass
  #   <tt>:length => 255</tt> or <tt>:length => 0..255</tt>.  Since DataMapper
  #   does not introspect for properties, this means that legacy database tables
  #   may need their <tt>String</tt> columns defined with a <tt>:length</tt> so
  #   that DM does not apply an un-needed length validation, or allow overflow.
  # * You may declare a Property with the data-type of <tt>Class</tt>.
  #   see SingleTableInheritance for more on how to use <tt>Class</tt> columns.
  class Property
    module PassThroughLoadDump
      # @api semipublic
      def load(value)
        unless value.nil?
          value = @type.load(value, self) if @type
          typecast(value)
        else
          value
        end
      end

      # Stub instance method for dumping
      #
      # @param value     [Object, nil]    value to dump
      #
      # @return [Object] Dumped object
      #
      # @api semipublic
      def dump(value)
        if @type
          @type.dump(value, self)
        else
          value
        end
      end
    end

    include DataMapper::Assertions
    include Subject
    extend Chainable
    extend Deprecate
    extend Equalizer

    deprecate :unique,    :unique?
    deprecate :nullable?, :allow_nil?
    deprecate :value,     :dump

    equalize :model, :name

    PRIMITIVES = [
      TrueClass,
      ::String,
      ::Float,
      ::Integer,
      ::BigDecimal,
      ::DateTime,
      ::Date,
      ::Time,
      ::Class
    ].to_set.freeze

    OPTIONS = [
      :accessor, :reader, :writer,
      :lazy, :default, :key, :field,
      :index, :unique_index,
      :unique, :allow_nil, :allow_blank, :required
    ]

    # Possible :visibility option values
    VISIBILITY_OPTIONS = [ :public, :protected, :private ].to_set.freeze

    attr_reader :primitive, :model, :name, :instance_variable_name,
      :type, :reader_visibility, :writer_visibility, :options,
      :default, :repository_name, :allow_nil, :allow_blank, :required

    class << self
      # @api public
      def descendants
        @descendants ||= []
      end

      # @api public
      def accepted_options
        @accepted_options ||= []
      end

      # @api public
      def accept_options(*args)
        accepted_options.concat(args)

        # Load Property options
        accepted_options.each do |property_option|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.#{property_option}(*args)                                  # def unique(*args)
              if args.any?                                                 #   if args.any?
                @#{property_option} = args.first                           #     @unique = args.first
              else                                                         #   else
                defined?(@#{property_option}) ? @#{property_option} : nil  #     defined?(@unique) ? @unique : nil
              end                                                          #   end
            end                                                            # end
          RUBY
        end

        descendants.each {|descendant| descendant.accept_options(*args)}
      end

      # Gives all the options set on this type
      #
      # @return [Hash] with all options and their values set on this type
      #
      # @api public
      def options
        options = {}
        accepted_options.each do |method|
          next if !respond_to?(method) || (value = send(method)).nil?
          options[method] = value
        end
        options
      end

      # Ruby primitive type to use as basis for this type. See
      # Property::PRIMITIVES for list of types.
      #
      # @param primitive [Class, nil]
      #   The class for the primitive. If nil is passed in, it returns the
      #   current primitive
      #
      # @return [Class] if the <primitive> param is nil, return the current primitive.
      #
      # @api public
      def primitive(primitive = nil)
        return @primitive if primitive.nil?
        @primitive = primitive
      end

      def nullable(value)
        # :required is preferable to :allow_nil, but :nullable maps precisely to :allow_nil
        warn "#nullable is deprecated, use #required instead (#{caller[0]})"
        allow_nil(value)
      end

      def inherited(base)
        descendants << base

        base.primitive primitive
        base.accept_options(*accepted_options)

        # inherit the options from the parent class
        base_options = base.options

        options.each do |key, value|
          base.send(key, value) unless base_options.key?(key)
        end
      end
    end

    accept_options *Property::OPTIONS

    # A hook to allow types to extend or modify property it's bound to.
    # Implementations are not supposed to modify the state of the type class, and
    # should produce no side-effects on the type class.
    def bind
      # no op
    end

    # Supplies the field in the data-store which the property corresponds to
    #
    # @return [String] name of field in data-store
    #
    # @api semipublic
    def field(repository_name = nil)
      self_repository_name = self.repository_name
      klass                = self.class

      if repository_name
        warn "Passing in +repository_name+ to #{klass}#field is deprecated (#{caller[0]})"

        if repository_name != self_repository_name
          raise ArgumentError, "Mismatching +repository_name+ with #{klass}#repository_name (#{repository_name.inspect} != #{self_repository_name.inspect})"
        end
      end

      # defer setting the field with the adapter specific naming
      # conventions until after the adapter has been setup
      @field ||= model.field_naming_convention(self_repository_name).call(self).freeze
    end

    # Returns true if property is unique. Serial properties and keys
    # are unique by default.
    #
    # @return [Boolean]
    #   true if property has uniq index defined, false otherwise
    #
    # @api public
    def unique?
      !!@unique
    end

    # Returns the hash of the property name
    #
    # This is necessary to allow comparisons between different properties
    # in different models, having the same base model
    #
    # @return [Integer]
    #   the property name hash
    #
    # @api semipublic
    def hash
      name.hash
    end

    # Returns index name if property has index.
    #
    # @return [Boolean, Symbol, Array]
    #   returns true if property is indexed by itself
    #   returns a Symbol if the property is indexed with other properties
    #   returns an Array if the property belongs to multiple indexes
    #   returns false if the property does not belong to any indexes
    #
    # @api public
    def index
      @index
    end

    # Returns true if property has unique index. Serial properties and
    # keys are unique by default.
    #
    # @return [Boolean, Symbol, Array]
    #   returns true if property is indexed by itself
    #   returns a Symbol if the property is indexed with other properties
    #   returns an Array if the property belongs to multiple indexes
    #   returns false if the property does not belong to any indexes
    #
    # @api public
    def unique_index
      @unique_index
    end

    # @api public
    def kind_of?(klass)
      super || klass == Property
    end

    # @api public
    def instance_of?(klass)
      super || klass == Property
    end

    # Returns whether or not the property is to be lazy-loaded
    #
    # @return [Boolean]
    #   true if the property is to be lazy-loaded
    #
    # @api public
    def lazy?
      @lazy
    end

    # Returns whether or not the property is a key or a part of a key
    #
    # @return [Boolean]
    #   true if the property is a key or a part of a key
    #
    # @api public
    def key?
      @key
    end

    # Returns whether or not the property is "serial" (auto-incrementing)
    #
    # @return [Boolean]
    #   whether or not the property is "serial"
    #
    # @api public
    def serial?
      @serial
    end

    # Returns whether or not the property must be non-nil and non-blank
    #
    # @return [Boolean]
    #   whether or not the property is required
    #
    # @api public
    def required?
      @required
    end

    # Returns whether or not the property can accept 'nil' as it's value
    #
    # @return [Boolean]
    #   whether or not the property can accept 'nil'
    #
    # @api public
    def allow_nil?
      @allow_nil
    end

    # Returns whether or not the property can be a blank value
    #
    # @return [Boolean]
    #   whether or not the property can be blank
    #
    # @api public
    def allow_blank?
      @allow_blank
    end

    # Returns whether or not the property is custom (not provided by dm-core)
    #
    # @return [Boolean]
    #   whether or not the property is custom
    #
    # @api public
    def custom?
      @custom
    end

    # Standardized reader method for the property
    #
    # @param [Resource] resource
    #   model instance for which this property is to be loaded
    #
    # @return [Object]
    #   the value of this property for the provided instance
    #
    # @raise [ArgumentError] "+resource+ should be a Resource, but was ...."
    #
    # @api private
    def get(resource)
      get!(resource)
    end

    # Fetch the ivar value in the resource
    #
    # @param [Resource] resource
    #   model instance for which this property is to be unsafely loaded
    #
    # @return [Object]
    #   current @ivar value of this property in +resource+
    #
    # @api private
    def get!(resource)
      resource.instance_variable_get(instance_variable_name)
    end

    # Provides a standardized setter method for the property
    #
    # @param [Resource] resource
    #   the resource to get the value from
    # @param [Object] value
    #   the value to set in the resource
    #
    # @return [Object]
    #   +value+ after being typecasted according to this property's primitive
    #
    # @raise [ArgumentError] "+resource+ should be a Resource, but was ...."
    #
    # @api private
    def set(resource, value)
      set!(resource, typecast(value))
    end

    # Set the ivar value in the resource
    #
    # @param [Resource] resource
    #   the resource to set
    # @param [Object] value
    #   the value to set in the resource
    #
    # @return [Object]
    #   the value set in the resource
    #
    # @api private
    def set!(resource, value)
      resource.instance_variable_set(instance_variable_name, value)
    end

    # Check if the attribute corresponding to the property is loaded
    #
    # @param [Resource] resource
    #   model instance for which the attribute is to be tested
    #
    # @return [Boolean]
    #   true if the attribute is loaded in the resource
    #
    # @api private
    def loaded?(resource)
      resource.instance_variable_defined?(instance_variable_name)
    end

    # Loads lazy columns when get or set is called.
    #
    # @param [Resource] resource
    #   model instance for which lazy loaded attribute are loaded
    #
    # @api private
    def lazy_load(resource)
      return if loaded?(resource)
      resource.__send__(:lazy_load, lazy_load_properties)
    end

    # @api private
    def lazy_load_properties
      @lazy_load_properties ||=
        begin
          properties = self.properties
          properties.in_context(lazy? ? [ self ] : properties.defaults)
        end
    end

    # @api private
    def properties
      @properties ||= model.properties(repository_name)
    end

    # @api semipublic
    def typecast(value)
      if @type && @type.respond_to?(:typecast)
        @type.typecast(value, self)
      elsif value.nil? || primitive?(value)
        value
      elsif respond_to?(:typecast_to_primitive)
        typecast_to_primitive(value)
      end
    end

    # Returns given value unchanged for core types and
    # uses +dump+ method of the property type for custom types.
    #
    # @param [Object] loaded_value
    #   the value to be converted into a storeable (ie., primitive) value
    #
    # @return [Object]
    #   the primitive value to be stored in the repository for +val+
    #
    # @api semipublic
    def dump(value)
      if custom?
        type.dump(loaded_value, self)
      else
        loaded_value
      end
    end

    # Test the value to see if it is a valid value for this Property
    #
    # @param [Object] loaded_value
    #   the value to be tested
    #
    # @return [Boolean]
    #   true if the value is valid
    #
    # @api semipulic
    def valid?(value, negated = false)
      dumped_value = dump(value)

      if required? && dumped_value.nil?
        negated || false
      else
        primitive?(dumped_value) || (dumped_value.nil? && (allow_nil? || negated))
      end
    end

    # Returns a concise string representation of the property instance.
    #
    # @return [String]
    #   Concise string representation of the property instance.
    #
    # @api public
    def inspect
      "#<#{self.class.name} @model=#{model.inspect} @name=#{name.inspect}>"
    end

    # Test a value to see if it matches the primitive type
    #
    # @param [Object] value
    #   value to test
    #
    # @return [Boolean]
    #   true if the value is the correct type
    #
    # @api semipublic
    def primitive?(value)
      value.kind_of?(primitive)
    end

    chainable do
      def self.new(model, name, options = {}, type = nil)
        super
      end
    end

    protected

    # @api semipublic
    def initialize(model, name, options = {}, type = nil)
      options       = options.to_hash.dup

      if type && !self.kind_of?(type)
        warn "#{type} < DataMapper::Type is deprecated, use the new DataMapper::Property API instead (#{caller[2]})"
        @type = type
      end

      reserved_method_names = DataMapper::Resource.instance_methods + DataMapper::Resource.private_instance_methods
      if reserved_method_names.map { |m| m.to_s }.include?(name.to_s)
        raise ArgumentError, "+name+ was #{name.inspect}, which cannot be used as a property name since it collides with an existing method"
      end

      assert_valid_options(options)

      predefined_options = self.class.options
      predefined_options.merge!(@type.options) if @type

      @repository_name        = model.repository_name
      @model                  = model
      @name                   = name.to_s.chomp('?').to_sym
      @options                = predefined_options.merge(options).freeze
      @instance_variable_name = "@#{@name}".freeze

      @primitive = self.class.primitive || @type.primitive
      @custom    = !@type.nil?
      @field     = @options[:field].freeze
      @default   = @options[:default]

      @serial       = @options.fetch(:serial,       false)
      @key          = @options.fetch(:key,          @serial)
      @unique       = @options.fetch(:unique,       @key ? :key : false)
      @required     = @options.fetch(:required,     @key)
      @allow_nil    = @options.fetch(:allow_nil,    !@required)
      @allow_blank  = @options.fetch(:allow_blank,  !@required)
      @index        = @options.fetch(:index,        false)
      @unique_index = @options.fetch(:unique_index, @unique)
      @lazy         = @options.fetch(:lazy,         false) && !@key

      determine_visibility

      @type ? @type.bind(self) : bind
    end

    # @api private
    def assert_valid_options(options)
      keys = options.keys

      if (unknown_keys = keys - self.class.accepted_options).any?
        raise ArgumentError, "options #{unknown_keys.map { |key| key.inspect }.join(' and ')} are unknown"
      end

      options.each do |key, value|
        boolean_value = value == true || value == false

        case key
          when :field
            assert_kind_of "options[:#{key}]", value, ::String

          when :default
            if value.nil?
              raise ArgumentError, "options[:#{key}] must not be nil"
            end

          when :serial, :key, :allow_nil, :allow_blank, :required, :auto_validation
            unless boolean_value
              raise ArgumentError, "options[:#{key}] must be either true or false"
            end

            if key == :required && (keys & [ :allow_nil, :allow_blank ]).size > 0
              raise ArgumentError, 'options[:required] cannot be mixed with :allow_nil or :allow_blank'
            end

          when :index, :unique_index, :unique, :lazy
            unless boolean_value || value.kind_of?(Symbol) || (value.kind_of?(Array) && value.any? && value.all? { |val| val.kind_of?(Symbol) })
              raise ArgumentError, "options[:#{key}] must be either true, false, a Symbol or an Array of Symbols"
            end

          when :length
            assert_kind_of "options[:#{key}]", value, Range, ::Integer

          when :size, :precision, :scale
            assert_kind_of "options[:#{key}]", value, ::Integer

          when :reader, :writer, :accessor
            assert_kind_of "options[:#{key}]", value, Symbol

            unless VISIBILITY_OPTIONS.include?(value)
              raise ArgumentError, "options[:#{key}] must be #{VISIBILITY_OPTIONS.join(' or ')}"
            end
        end
      end
    end

    # Assert given visibility value is supported.
    #
    # Will raise ArgumentError if this Property's reader and writer
    # visibilities are not included in VISIBILITY_OPTIONS.
    #
    # @return [undefined]
    #
    # @raise [ArgumentError] "property visibility must be :public, :protected, or :private"
    #
    # @api private
    def determine_visibility
      default_accessor = @options[:accessor] || :public

      @reader_visibility = @options[:reader] || default_accessor
      @writer_visibility = @options[:writer] || default_accessor
    end
  end # class Property
end
