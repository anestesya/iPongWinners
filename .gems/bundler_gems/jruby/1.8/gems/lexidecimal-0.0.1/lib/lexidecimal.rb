require 'bigdecimal'

module Lexidecimal
  MINUS = '-'.freeze
  PLUS = 'p'.freeze
  
  def self.invert string
    string.each_char.map{|d| 9-d.to_i}.join
  end
  
  def self.int_to_string num, sign=nil, negative=nil
    return '0' if num == 0
    
    if sign.nil?
      if num < 0
        sign = MINUS
        negative = true
        num = -num
      else
        sign = PLUS
        negative = false
      end
    end
    
    string = num.to_s
    string = self.invert string if negative
    
    length = string.length
    if length > 1
      "#{sign}#{self.int_to_string length, sign, negative}#{string}"
    else
      "#{sign}#{string}"
    end
  end
  
  def self.decimal_to_string num
    sign, digits, base, exponent = num.split
    
    return '0' if digits == '0'
    
    negative = (sign < 1)
    if negative
      digits = self.invert digits
      sign = MINUS
      antisign = PLUS
    else
      sign = PLUS
      antisign = MINUS
    end
    
    "#{sign}#{self.int_to_string(negative ? -exponent : exponent)}#{digits}#{antisign}"
  end
  
  def self.string_to_int string
    self.enum_to_int string.each_char
  end
  
  def self.enum_to_int enum
    sign = enum.next
    return 0 if sign == '0'
    count = 0
    while (cur = enum.next) == sign
      count += 1
    end
    negative = (sign == MINUS)
    length = cur.to_i
    length = 9 - length if negative
    count.times do
      new_length = 0
      length.times do
        new_length *= 10
        digit = enum.next.to_i
        digit = 9 - digit if negative
        new_length += digit
      end
      length = new_length
    end
    negative ? -length : length
  end
  
  def self.string_to_decimal string
    self.enum_to_decimal string.each_char
  end
  
  def self.enum_to_decimal enum
    sign = enum.next
    negative = (sign == MINUS)
    antisign = (negative ? PLUS : MINUS)
    
    exponent = self.enum_to_int enum
    exponent = -exponent if negative
    
    digits = ''
    
    while (cur = enum.next) != antisign
      if negative
        digits << (9 - cur.to_i).to_s
      else
        digits << cur
      end
    end
    
    BigDecimal.new "#{negative ? '-' : ''}0.#{digits}e#{exponent}"
  end
end
