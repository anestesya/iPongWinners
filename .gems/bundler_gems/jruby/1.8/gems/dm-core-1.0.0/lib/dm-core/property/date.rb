require 'dm-core/property/typecast/time'

module DataMapper
  class Property
    class Date < Object
      include PassThroughLoadDump
      include Typecast::Time

      primitive ::Date

      # Typecasts an arbitrary value to a Date
      # Handles both Hashes and Date instances.
      #
      # @param [#to_mash, #to_s] value
      #   value to be typecast
      #
      # @return [Date]
      #   Date constructed from value
      #
      # @api private
      def typecast_to_primitive(value)
        if value.respond_to?(:to_date)
          value.to_date
        elsif value.respond_to?(:to_mash)
          typecast_hash_to_date(value)
        else
          ::Date.parse(value.to_s)
        end
      rescue ArgumentError
        value
      end

      # Creates a Date instance from a Hash with keys :year, :month, :day
      #
      # @param [#to_mash] value
      #   value to be typecast
      #
      # @return [Date]
      #   Date constructed from hash
      #
      # @api private
      def typecast_hash_to_date(value)
        ::Date.new(*extract_time(value)[0, 3])
      end
    end # class Date
  end # class Property
end # module DataMapper
