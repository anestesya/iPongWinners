module DataMapper
  class Property
    class AppEngineNative < Property
      primitive ::Object
      
      def dump(value)
        value
      end
      
      def load(value)
        value
      end
    end
    IMHandle = GeoPt = User = AppEngineNative
  end
end