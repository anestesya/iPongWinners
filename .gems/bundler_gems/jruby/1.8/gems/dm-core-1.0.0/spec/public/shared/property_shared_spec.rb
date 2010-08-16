share_examples_for 'A public Property' do
  before :all do
    %w[ @type @primitive @name @value @other_value ].each do |ivar|
      raise "+#{ivar}+ should be defined in before block" unless instance_variable_defined?(ivar)
    end

    module ::Blog
      class Article
        include DataMapper::Resource
        property :id, Serial
      end
    end

    @model = Blog::Article
  end

  describe "with a sub-type" do
    before :all do
      class ::SubType < @type; end
      @subtype = ::SubType
      @type.accept_options :foo, :bar
    end

    after :all do
      Object.send(:remove_const, :SubType)
    end

    describe ".accept_options" do
      describe "when provided :foo, :bar" do
        it "should add new options" do
          [@type, @subtype].each do |type|
            type.accepted_options.include?(:foo).should be(true)
            type.accepted_options.include?(:bar).should be(true)
          end
        end

        it "should create predefined option setters" do
          [@type, @subtype].each do |type|
            type.should respond_to(:foo)
            type.should respond_to(:bar)
          end
        end

        describe "auto-generated option setters" do
          before :all do
            [@type, @subtype].each do |type|
              type.foo true
              type.bar 1
              @property = type.new(@model, @name)
            end
          end

          it "should set the pre-defined option values" do
            @property.options[:foo].should == true
            @property.options[:bar].should == 1
          end
        end
      end
    end

    describe ".descendants" do
      it "should include the sub-type" do
        @type.descendants.include?(SubType).should be(true)
      end
    end

    describe ".primitive" do
      it "should return the primitive class" do
        [@type, @subtype].each do |type|
          type.primitive.should be(@primitive)
        end
      end

      it "should change the primitive class" do
        @subtype.primitive Object
        @subtype.primitive.should be(Object)
      end
    end
  end

  [:allow_blank, :allow_nil].each do |opt|
    describe "##{method = "#{opt}?"}" do
      [true, false].each do |value|
        describe "when created with :#{opt} => #{value}" do
          before :all do
            @property = @type.new(@model, @name, opt => value)
          end

          it "should return #{value}" do
            @property.send(method).should be(value)
          end
        end
      end

      describe "when created with :#{opt} => true and :required => true" do
        it "should fail with ArgumentError" do
          lambda {
            @property = @type.new(@model, @name, opt => true, :required => true)
          }.should raise_error(ArgumentError,
            "options[:required] cannot be mixed with :allow_nil or :allow_blank")
        end
      end
    end
  end

  [:key?, :required?, :index, :unique_index, :unique?].each do |method|
    describe "##{method}" do
      [true, false].each do |value|
        describe "when created with :#{method} => #{value}" do
          before :all do
            opt = method.to_s.chomp('?').to_sym
            @property = @type.new(@model, @name, opt => value)
          end

          it "should return #{value}" do
            @property.send(method).should be(value)
          end
        end
      end
    end
  end

  describe "#lazy?" do
    describe "when created with :lazy => true, :key => false" do
      before :all do
        @property = @type.new(@model, @name, :lazy => true, :key => false)
      end

      it "should return true" do
        @property.lazy?.should be(true)
      end
    end

    describe "when created with :lazy => true, :key => true" do
      before :all do
        @property = @type.new(@model, @name, :lazy => true, :key => true)
      end

      it "should return false" do
        @property.lazy?.should be(false)
      end
    end
  end

  describe "#custom?" do
    describe "when DM::Type is not provided" do
      before :all do
        @property = @type.new(@model, @name)
      end

      it "should be false" do
        @property.custom?.should be(false)
      end
    end
  end

  [:instance_of?, :kind_of?].each do |method|
    describe "##{method}" do
      before :all do
        @property = @type.new(@model, @name)
      end

      describe "when provided Property" do
        it "should return true" do
          @property.send(method, DataMapper::Property).should be(true)
        end
      end

      describe "when provided property class" do
        it "should return true" do
          @property.send(method, @type).should be(true)
        end
      end
    end
  end
end
